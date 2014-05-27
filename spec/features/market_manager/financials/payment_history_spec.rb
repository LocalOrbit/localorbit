require 'spec_helper'
feature "Payment history" do
  let(:market_ach_balanced_uri) { "http://balanced.example.com/12345" }
  let(:ach_balanced_uri) { "http://balanced.example.com/123456" }
  let(:cc_balanced_uri) { "http://balanced.example.com/1234567" }

  let!(:market)             { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:market_ach_account) { create(:bank_account, :checking, last_four: "7676", balanced_uri: market_ach_balanced_uri, bankable: market) }
  let!(:service_fee)        { create(:payment, payment_method: 'ach', payment_type: 'service', payer: market, amount: 99.00) }

  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:seller2) { create(:organization, markets: [market]) }

  let!(:buyer)  { create(:organization, markets: [market], can_sell: false) }
  let!(:user)    { create(:user, managed_markets: [market]) }

  let(:payment_day) { DateTime.parse("May 9, 2014, 11:00:00") }

  let!(:ach_account) { create(:bank_account, :checking, last_four: "9983", balanced_uri: ach_balanced_uri, bankable: buyer) }
  let!(:cc_account) { create(:bank_account, :credit_card, last_four: "7732", balanced_uri: cc_balanced_uri, bankable: buyer) }

  before do
    Timecop.freeze(payment_day) do
      order_item = create(:order_item, unit_price: 6.50, quantity: 2)
      create(:order, items: [order_item], organization: buyer, payment_method: "purchase order", total_cost: 13.00)

      order_item = create(:order_item, unit_price: 36.00, quantity: 2)
      create(:order, items: [order_item], organization: buyer, payment_method: "ach", total_cost: 72.00)

      order_item = create(:order_item, unit_price: 129.00, quantity: 1)
      create(:order, items: [order_item], organization: buyer, payment_method: "credit card", total_cost: 129.00)

      orders = []
      4.times do |i|
        order_item = create(:order_item, unit_price: 20.00 + i, quantity: 1)
        orders << create(:order, items: [order_item], organization: buyer, payment_method: ["purchase order", "purchase order", "ach", "credit card"][i], payment_status: "paid")
      end

      orders.each_with_index do |order, i|
        create(:payment, payment_method: ["cash", "check", "ach", "credit card"][i], payee: market, payer: buyer, orders: [order], amount: order.total_cost)
      end

      check_payment = orders[1].payments.first
      check_payment.note = "#12345"
      check_payment.save!

      ach_payment = orders[2].payments.first
      ach_payment.balanced_uri = ach_balanced_uri
      ach_payment.save!

      cc_payment = orders[3].payments.first
      cc_payment.balanced_uri = cc_balanced_uri
      cc_payment.save!
    end
  end

  def payment_row(amount)
    Dom::Admin::Financials::PaymentRow.find_by_amount(amount)
  end

  scenario "Market manager can view payment history" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    click_link "Financials"

    expect(page).to have_content("Overview")

    click_link "Review Payment History"

    expect(page).to have_content("Payment History")
    expect(page).to have_content("Payment Date")
    expect(page).to have_content("Description")
    expect(page).to have_content("Payment Method")
    expect(page).to have_content("Amount")

    expect(payment_row("$13.00")).to be_nil
    expect(payment_row("$72.00")).to be_nil
    expect(payment_row("$129.00")).to be_nil

    expect(payment_row("$20.00")).not_to be_nil
    expect(payment_row("$20.00").payment_method).to eql("Cash")

    expect(payment_row("$21.00")).not_to be_nil
    expect(payment_row("$21.00").payment_method).to eql("Check: #12345")

    expect(payment_row("$22.00")).not_to be_nil
    expect(payment_row("$22.00").payment_method).to eql("ACH: *********9983")

    expect(payment_row("$23.00")).not_to be_nil
    expect(payment_row("$23.00").payment_method).to eql("Credit Card: ************7732")

    expect(payment_row("$99.00")).not_to be_nil
    expect(payment_row("$99.00").payment_method).to have_content("ACH")
  end
end
