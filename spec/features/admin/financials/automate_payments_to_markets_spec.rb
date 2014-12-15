require "spec_helper"

feature "Payment of hub and delivery fees to Markets on the Automate plan", :js  do

  include_context "the mini market"
  
  let(:order_time) { Time.zone.parse("May 20, 2014 2:00 PM") }
  let(:deliver_time) { Time.zone.parse("May 25, 2014 3:30 PM") }
  let(:now_time) { Time.zone.parse("May 30, 2014 1:15 AM") }
  let!(:m0) { Generate.market_with_orders }
  let!(:m00) { Generate.market_with_orders }

  let!(:m1) { Generate.market_with_orders(
                market_name: "Four Pigs",
                order_time: order_time, 
                deliver_time: deliver_time,
                paid_with: "credit card",
                delivered: "delivered",
                num_orders: 4,
                num_sellers: 2,
                delivery_fee_percent: 12.to_d
  )}
  let!(:m2) { Generate.market_with_orders(
                market_name: "Too Hoss",
                order_time: order_time, 
                deliver_time: deliver_time,
                paid_with: "credit card",
                delivered: "delivered",
                delivery_fee_percent: 17.to_d
  )}

  # TODO: the following SHOULD hold but is not implemented that way.
  # This market's orders will be too late to be considered payable:
  # let!(:m3) { Generate.market_with_orders(
  #               order_time: now_time,
  #               deliver_time: now_time+1.day,
  #               paid_with: "credit card",
  #               delivered: "delivered",
  #               delivery_fee_percent: 55.to_d
  # )}

  let!(:market_payment_0) {
    market = m1[:market]
    bank_account = market.bank_accounts.first
    create(:payment, payment_type: "market payment", payee: market, orders: [ m1[:orders][0] ], market: market, bank_account: bank_account, payment_method: "ach", amount: 100)
  }


  before do
    switch_to_subdomain mini_market.subdomain
    sign_in_as aaron
  end

  it "displays all pending Market payments info and lets you pay one of the Markets" do
    begin 
      visit admin_financials_automate_market_payments_path
      expect(page).to have_content("Make Payments to Markets on Automate Plan")

      market_a = m1[:market]
      order_a1 = m1[:orders][0] # should end up being excluded due to a market payment
      order_a2 = m1[:orders][1]
      order_a4 = m1[:orders][3]

      market_b = m2[:market]
      order_b = m2[:orders][0]

      verify_market_payment_section(
        market: market_b,
        market_name: market_b.name, 
        orders: [
          :order_number,        :owed,   :order_total, :delivery_fee, :market_fee,
          order_b.order_number, "$0.29", "$0.89",      "$0.19",       "$0.10", 
          # ...there are more rows but we're not looking at all 
        ], 
        totals: {
          owed: "$0.57",
          order_total: "$1.78",
          delivery_fee: "$0.37",
          market_fee: "$0.20",
        },
        bank_accounts: [
          "LMCU",
        ]
      )

      verify_market_payment_section(
        market: market_a,
        market_name: market_a.name,
        orders: [
          :order_number,         :owed,   :order_total, :delivery_fee, :market_fee,
          order_a2.order_number, "$0.23", "$0.83",      "$0.13",       "$0.10", 
          order_a4.order_number, "$0.23", "$0.83",      "$0.13",       "$0.10", 
          # ...there are more rows but we're not looking at all 
        ], 
        totals: {
          owed: "$0.68",
          order_total: "$2.49",
          delivery_fee: "$0.38",
          market_fee: "$0.30",
        },
        bank_accounts: [
          "LMCU",
        ]
      )


      #
      # Setup some vars to use in expectations
      #

      # The section on the page for the first Market:
      section = section_for(market_a.name)

      # Expected payment / owed amounts to see:
      expected_market_fee_str = section.totals.market_fee
      expected_market_fee = section.totals.market_fee_as_decimal

      expected_delivery_fee_str = section.totals.delivery_fee
      expected_delivery_fee = section.totals.delivery_fee_as_decimal

      expected_bank_account = market_bank_account(market_a, "LMCU")
      expected_orders = section.orders.map do |o|
        Order.find_by_order_number(o.order_number)
      end
      expected_market = market_a


      # Make sure order_a1 is not in the table; it's been paid for via 'market payment' and shouldn't be paid again:
      order_nums = section_for(market_a.name).orders.map do |o| o.order_number end
      expect(order_nums).not_to include(order_a1.order_number)


      #
      # Trigger payment to Market!
      #
      section.select_bank_account expected_bank_account.display_name
      section.pay_button.click

      expect(page).to have_content("Payment recorded")

      #
      # Peek at captured Payment info and get ahold of the market fee and delivery fee payments
      # by name:
      #
      payments = {}
      captured_payments.each do |h|
        if h[:description] =~ /market fee.*automate/i
          payments[:market_fee_payment] = h[:payment]
        elsif h[:description] =~ /delivery fee.*automate/i
          payments[:delivery_fee_payment] = h[:payment]
        else
          raise "Captured unexpected payment: #{h.inspect}"
        end
      end

      # Make sure we got em both:
      expect(payments.keys).to contain_exactly(:market_fee_payment, :delivery_fee_payment), "Didn't capture the payments we wanted to see"
      # expect(payments.keys).to contain_exactly(:market_fee_payment), "Didn't capture the payments we wanted to see"
        
      market_fee_payment = payments[:market_fee_payment]
      delivery_fee_payment = payments[:delivery_fee_payment]

      #
      # Verify Market Fee Payment details:
      # 
      expect(market_fee_payment.payment_type).to eq "hub fee"
      expect(market_fee_payment.payment_method).to eq "ach"
      expect(market_fee_payment.status).to eq "pending"
      expect(market_fee_payment.payee).to eq expected_market
      expect(market_fee_payment.amount).to eq expected_market_fee
      expect(market_fee_payment.bank_account).to eq expected_bank_account
      expect(market_fee_payment.market).to eq expected_market
      expect(market_fee_payment.orders).to contain_exactly(*expected_orders)

      # Check notification for Market Fee Payment
      mail = ActionMailer::Base.deliveries[0] # Market Fee Payment is probably first.
      expect(mail).to be, "No Market Fee email sent"
      expect(mail.to).to eq market_a.managers.map(&:email)
      expect(mail.subject).to eq "You Have Received a Payment"
      expect(mail.body).to match(/You have received a payment/i)
      expect(mail.body).to match(/payment was sent to.*#{market_a.name}/i)
      expect(mail.body).to match(/#{Regexp.escape(expected_market_fee_str)}/)
      expect(mail.body).to match(/Visit #{expected_market.name}/)
      
      #
      # Verify Delivery Fee Payment details:
      # 
      expect(delivery_fee_payment.payment_type).to eq "delivery fee"
      expect(delivery_fee_payment.payment_method).to eq "ach"
      expect(delivery_fee_payment.status).to eq "pending"
      expect(delivery_fee_payment.payee).to eq expected_market

      expect(delivery_fee_payment.amount).to eq expected_delivery_fee
      expect(delivery_fee_payment.bank_account).to eq expected_bank_account
      expect(delivery_fee_payment.market).to eq expected_market
      expect(delivery_fee_payment.orders).to contain_exactly(*expected_orders)

      # Check notification for Market Fee Payment
      mail = ActionMailer::Base.deliveries[1] # Market Fee Payment is probably first.
      expect(mail).to be, "No Delivery Fee email sent"
      expect(mail.to).to eq market_a.managers.map(&:email)
      expect(mail.subject).to eq "You Have Received a Payment"
      expect(mail.body).to match(/You have received a payment/i)
      expect(mail.body).to match(/payment was sent to.*#{market_a.name}/i)
      expect(mail.body).to match(/#{Regexp.escape(expected_delivery_fee_str)}/)
      expect(mail.body).to match(/Visit #{expected_market.name}/)

    rescue Exception => e
      puts ">>>>>> Payments to Market SPEC FAILED: #{e.message} <<<<<<<<"
      puts ">>>>>>BODY:\n#{page.body}"
      puts ">>>>>> m1:"
      puts m1.inspect
      puts ">>>>>> m2:"
      puts m2.inspect
      # puts ">>>>>> m3:"
      # puts m3.inspect

      raise e
    end
  end

  #
  # HELPERS
  #
  def section_for(market_name)
    Dom::Admin::Financials::Automate::MarketSection.find_by_market_name(market_name)
  end

  def verify_market_payment_section(market:,market_name:, orders:, totals:, bank_accounts:)
    # Find the market's payment section on the page:
    section = section_for(market_name)
    expect(section).to be, "Couldn't see a MarketSection for '#{market_name}'. HTML=#{page.body}"

    # Check orders:
    tabulate(5, orders) do |order|
      table_row = section.orders.detect do |o| o.order_number == order[:order_number] end
      if table_row
        expect(table_row.attributes).to eq(order)
      else
        expect(table_row).to be, "Can't see order '#{order[:order_number]}' for market '#{market_name}'"
      end
    end

    # Check totals:
    expect(section.totals.attributes).to eq(totals)

    # Check bank accounts:
    bank_accounts.each do |name_matcher|
      acct = market_bank_account(market, name_matcher)
      name = acct.display_name
      id = acct.id
      section.node.find("select option[value='#{id}']", text: name)
    end

    # See the button:
    section.pay_button
  end

  def market_bank_account(market, name_matcher)
    acct = market.bank_accounts.detect { |a| a.display_name =~ /#{name_matcher}/ } 
    expect(acct).to be, "market #{market.name} doesn't have a BankAccount whose display_name matches #{name_matcher.inspect}.  It has names #{market.bank_accounts.map {|ba|ba.display_name}} from #{market.bank_accounts.to_a.inspect}"
    acct
  end

  def captured_payments
    Financials::PaymentExecutor.previously_captured_payments
  end

end

