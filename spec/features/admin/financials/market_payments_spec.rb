require "spec_helper"

feature "Payment of 'market payments' to Markets on non-Automate plans", :js  do

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
                delivery_fee_percent: 12.to_d,
                plan: :start_up
  )}
  let!(:m2) { Generate.market_with_orders(
                market_name: "Too Hoss",
                order_time: order_time, 
                deliver_time: deliver_time,
                paid_with: "credit card",
                delivered: "delivered",
                delivery_fee_percent: 17.to_d,
                plan: :grow
  )}
  # This market's orders will be too late to be considered payable:
  let!(:m3) { Generate.market_with_orders(
                order_time: now_time,
                deliver_time: now_time+1.day,
                paid_with: "credit card",
                delivered: "delivered",
                delivery_fee_percent: 55.to_d
  )}

  let!(:seller_payment_0) {
    market = m1[:market]
    order = m1[:orders][0]
    seller = order.items.first.seller
    bank_account = seller.bank_accounts.first

    # Generate a seller payment for the first order in m1 such that we'd expect it to be excluded from the display
    create(:payment, payment_type: "seller payment", payee: seller, orders: [ m1[:orders][0] ], market: market, bank_account: bank_account, payment_method: "ach", amount: 100)

    # Update the SECOND order to be from a non-Balanced payment provider, such that we expect it to be excluded
    m1[:orders][1].update(payment_provider: PaymentProvider::Stripe.id.to_s)
  }

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in_as aaron
  end

  it "displays all pending Seller payments info and lets you pay one of the Markes" 
  # TODO: this entire test was simply missing from the suite.  Today's focus was just to ensure the proper filtering
  # is in place wrt seller payments, see the spec below which focuses on that.

  #
  # HELPERS
  #
  def section_for(market_nam)
    Dom::Admin::Financials::MarketSection.find_by_market_name(market_name)
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

end

