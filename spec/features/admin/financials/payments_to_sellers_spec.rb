require "spec_helper"

feature "Payments to Sellers on plans with Automatic Payments", :js, :focus  do

  include_context "the mini market"
  
  let(:order_time) { Time.zone.parse("May 20, 2014 2:00 PM") }
  let(:deliver_time) { Time.zone.parse("May 25, 2014 3:30 PM") }
  let(:now_time) { Time.zone.parse("May 30, 2014 1:15 AM") }
  let!(:m0) { Generate.market_with_orders }
  let!(:m00) { Generate.market_with_orders }

  let!(:m1) { Generate.market_with_orders(
                order_time: order_time, 
                deliver_time: deliver_time,
                paid_with: "credit card",
                delivered: "delivered",
                num_orders: 4,
                num_sellers: 2
  )}
  let!(:m2) { Generate.market_with_orders(
                order_time: order_time, 
                deliver_time: deliver_time,
                paid_with: "credit card",
                delivered: "delivered"
  )}
  # This market's orders will be too late to be considered payable:
  let!(:m3) { Generate.market_with_orders(
                order_time: now_time,
                deliver_time: now_time+1.day,
                paid_with: "credit card",
                delivered: "delivered"
  )}


  before do
    switch_to_subdomain mini_market.subdomain
    sign_in_as aaron
  end

  it "displays all pending Seller payments info and lets you pay one of the Sellers" do
    begin 
      visit admin_financials_automate_seller_payments_path
      expect(page).to have_content("Make Weekly Payments to Sellers")

      seller_a = m1[:seller_organizations][1]
      order_a2 = m1[:orders][1]
      order_a4 = m1[:orders][3]
      seller_b = m2[:seller_organizations][0]
      order_b = m2[:orders][0]

      verify_seller_payment_section(
        seller: seller_b,
        seller_name: seller_b.name, 
        orders: [
          :order_number, :net_sales, :gross_sales, :market_fees, :transaction_fees, :payment_processing_fees, :discounts, :delivery_status, :buyer_payment_status, :seller_payment_status, :payment_method, 
          order_b.order_number, "$0.10", "$1.10", "$0.10", "$0.20", "$0.30", "$0.40", "Delivered", "Paid", "Unpaid", "Credit Card",
        ], 
        totals: {
          net_sales: "$0.10",
          gross_sales: "$1.10",
          market_fees: "$0.10",
          transaction_fees: "$0.20",
          payment_processing_fees: "$0.30",
          discounts: "$0.40",
        },
        bank_accounts: [
          "East Bank",
          "North Bank"
        ]
      )

      verify_seller_payment_section(
        seller: seller_a,
        seller_name: seller_a.name,
        orders: [
          :order_number, :net_sales, :gross_sales, :market_fees, :transaction_fees, :payment_processing_fees, :discounts, :delivery_status, :buyer_payment_status, :seller_payment_status, :payment_method, 
          order_a2.order_number, "$0.10", "$1.10", "$0.10", "$0.20", "$0.30", "$0.40", "Delivered", "Paid", "Unpaid", "Credit Card",
          order_a4.order_number, "$0.10", "$1.10", "$0.10", "$0.20", "$0.30", "$0.40", "Delivered", "Paid", "Unpaid", "Credit Card",
        ], 
        totals: {
          net_sales: "$0.20",
          gross_sales: "$2.20",
          market_fees: "$0.20",
          transaction_fees: "$0.40",
          payment_processing_fees: "$0.60",
          discounts: "$0.80",
        },
        bank_accounts: [
          "East Bank",
          "North Bank"
        ]
      )



      section = section_for(seller_a.name)

      expected_payment_amount_str = section.totals.net_sales
      expected_payment_amount = section.totals.net_sales_as_decimal
      expected_bank_account = seller_bank_account(seller_a, "North Bank")
      expected_orders = section.orders.map do |o|
        Order.find_by_order_number(o.order_number)
      end
      expected_market = seller_a.markets.first

      # Pay!
      section.select_bank_account expected_bank_account.display_name
      section.pay_button.click

      expect(page).to have_content("Payment recorded")

      #
      # Peek at captured Payment info:
      #
      payment = only_captured_payment[:payment]
      desc = only_captured_payment[:description]

      # See the proper description sent to the executor:
      expect(desc).to match(/payment to seller/i)
      expect(desc).to match(/automate/i)

      # Verify Payment details:
      expect(payment.payment_type).to eq "seller payment"
      expect(payment.payment_method).to eq "ach"
      expect(payment.status).to eq "pending"
      expect(payment.payee).to eq seller_a
      expect(payment.amount).to eq expected_payment_amount
      expect(payment.bank_account).to eq expected_bank_account
      expect(payment.market).to eq expected_market
      expect(payment.orders).to contain_exactly(*expected_orders)

      # Check notification
      mail = ActionMailer::Base.deliveries.first
      expect(mail).to be, "No email sent"
      expect(mail.to).to eq seller_a.users.map(&:email)
      expect(mail.subject).to eq "You Have Received a Payment"
      expect(mail.body).to match(/You have received a payment/i)
      expect(mail.body).to match(/payment was sent to.*#{seller_a.name}/i)
      expect(mail.body).to match(/#{Regexp.escape(expected_payment_amount_str)}/)
      expect(mail.body).to match(/Visit #{expected_market.name}/)
    rescue Exception => e
      puts ">>>>>> Payments to Sellers SPEC FAILED: #{e.message} <<<<<<<<"
      puts ">>>>>>BODY:\n#{page.body}"
      puts ">>>>>> m1:"
      puts m1.inspect
      puts ">>>>>> m2:"
      puts m2.inspect
      puts ">>>>>> m3:"
      puts m3.inspect

      raise e
    end
  end

  #
  # HELPERS
  #
  def section_for(seller_name)
    Dom::Admin::Financials::Automate::SellerSection.find_by_seller_name(seller_name)
  end

  def verify_seller_payment_section(seller:,seller_name:, orders:, totals:, bank_accounts:)
    # Find the seller's payment section on the page:
    section = section_for(seller_name)
    expect(section).to be, "Couldn't see a SellerSection for '#{seller_name}'. HTML=#{page.body}"

    # Check orders:
    tabulate(11, orders) do |order|
      table_row = section.orders.detect do |o| o.order_number == order[:order_number] end
      if table_row
        expect(table_row.attributes).to eq(order)
      else
        expect(table_row).to be, "Can't see order '#{order[:order_number]}' for seller '#{seller_name}'"
      end
    end

    # Check totals:
    expect(section.totals.attributes).to eq(totals)

    # Check bank accounts:
    bank_accounts.each do |name_matcher|
      acct = seller_bank_account(seller, name_matcher)
      name = acct.display_name
      id = acct.id
      section.node.find("select option[value='#{id}']", text: name)
    end

    # See the button:
    section.pay_button
  end

  def seller_bank_account(seller_org, name_matcher)
    acct = seller_org.bank_accounts.detect { |a| a.display_name =~ /#{name_matcher}/ } 
    expect(acct).to be, "Seller #{seller_org.name} doesn't have a BankAccount whose display_name matches #{name_matcher.inspect}.  It has names #{seller_org.bank_accounts.map {|ba|ba.display_name}} from #{seller_org.bank_accounts.to_a.inspect}"
    acct
  end

  def captured_payments
    Financials::PaymentExecutor.previously_captured_payments
  end

  def only_captured_payment
    expect(captured_payments.length).to eq(1), "Should be 1 and only 1 captured payment. Instead there are #{captured_payments.length}: #{captured_payments.inspect}"
    captured_payments.first
  end
end

