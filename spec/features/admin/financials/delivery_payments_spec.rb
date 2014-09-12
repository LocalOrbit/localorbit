require 'spec_helper'

feature 'Admin can pay Market for delivery fee' do
  let!(:user) { create(:user, :admin) }
  let!(:market) { create(:market, active: true, balanced_customer_uri: "/v1/customers/CU2IxeLNkFjoIWunLHrNF42h") }
  let!(:bank_account) { create(:bank_account, :checking, :verified, bankable: market, balanced_uri: "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/bank_accounts/BA2HLalCQhL522m6I7VSkuih") }
  let!(:order) { create(:order, delivery_fees: 5.00, payment_method: "ach", payment_status: "paid", market: market)}
  let!(:order_item) { create(:order_item, delivery_status: "delivered") }

  before do
    sign_in_as user
  end

  it "navigating to" do
    click_link "Market Admin"
    click_link "Admin Financials"
    click_link "Delivery Payments"

    expect(page).to have_content("Market Delivery Fee Payments")
  end

  it "shows the markets that have delivered orders" do
    visit "/admin/financials/admin/delivery_payments"

    expect(page).to have_content(market.name)
    expect(page).to have_content(order.number)
    expect(page).to have_content("5.00")

    expect(page).to have_button("Pay #{market.name}")
  end


  it "runs a delivery payment through balanced", :vcr do
    market_manager = create(:user, managed_markets: [market])

    visit "/admin/financials/admin/delivery_payments"

    click_button "Pay #{market.name}"

    expect(page).to have_content("Payment made for #{market.name}")

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    open_last_email
    expect(current_email).to be_delivered_to(market_manager.email)
  end

  it "if there are no market managers we do not send an email", :vcr do
    visit "/admin/financials/admin/delivery_payments"

    click_button "Pay #{market.name}"

    expect(page).to have_content("Payment made for #{market.name}")

    expect(ActionMailer::Base.deliveries.size).to eq(0)
  end
end