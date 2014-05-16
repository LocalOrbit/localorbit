require 'spec_helper'
feature "Payment history" do
  let!(:market)  { create(:market, po_payment_term: 30, timezone: "Eastern Time (US & Canada)") }
  let!(:seller)  { create(:organization, markets: [market]) }
  let!(:seller2) { create(:organization, markets: [market]) }

  let!(:buyer)  { create(:organization, markets: [market], can_sell: false) }
  let!(:user)    { create(:user, organizations: [buyer]) }
  let(:payment_day) { DateTime.parse("May 9, 2014, 11:00:00") }

  before do
    Timecop.freeze(payment_day) do
      create(:order, :with_items, organization: buyer, payment_method: "purchase order", total_cost: 13.00)
      create(:order, :with_items, organization: buyer, payment_method: "ach", total_cost: 72.00)
      create(:order, :with_items, organization: buyer, payment_method: "credit card", total_cost: 129.00)

      orders = []
      3.times do |i|
        orders << create(:order, :with_items, organization: buyer, payment_method: ["purchase order", "ach", "credit card"][i], payment_status: "paid", total_cost: 20.00 + i)
      end

      orders.each_with_index do |order, i|
        create(:payment, payment_type: ["cash", "ach", "credit card"][i], payee: market, orders: [order], amount: order.total_cost)
      end
    end
  end

  def payment_row(amount)
    Dom::Admin::Financials::PaymentRow.find_by_amount(amount)
  end

  scenario "Buyer can view their purchase history" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    click_link "Financials"
    save_and_open_page

    expect(page).to have_content("Payment History")
    expect(page).to have_content("Payment Date")
    expect(page).to have_content("Order #")
    expect(page).to have_content("Payment Method")
    expect(page).to have_content("Amount")

    expect(payment_row("$13.00")).to be_nil
    expect(payment_row("$72.00")).to be_nil
    expect(payment_row("$129.00")).to be_nil

    expect(payment_row("$20.00")).not_to be_nil
    expect(payment_row("$21.00")).not_to be_nil
    expect(payment_row("$22.00")).not_to be_nil
  end
end
