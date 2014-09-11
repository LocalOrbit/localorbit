require "spec_helper"

feature "Admin service payments" do
  let!(:user) { create(:user, :admin) }
  let!(:deactivated_market) { create(:market, active: false) }
  let!(:unconfigured_market) { create(:market, active: true) }
  let!(:configured_market) { create(:market, active: true, plan_fee: 99.99, plan_interval: 1, plan_start_at: 1.day.ago, balanced_customer_uri: "/v1/customers/CU2IxeLNkFjoIWunLHrNF42h") }
  let!(:plan_bank_account) { create(:bank_account, :checking, :verified, bankable: configured_market, balanced_uri: "/v1/marketplaces/TEST-MP4X7mSSQwAyDzwUfc5TAQ7D/bank_accounts/BA2HLalCQhL522m6I7VSkuih") }
  let(:payment_button_text) { "Run Now" }

  before do
    configured_market.update_attributes!(plan_bank_account: plan_bank_account)
    sign_in_as user
  end

  it "navigating to" do
    click_link "Market Admin"
    click_link "Admin Financials"
    click_link "Service Payments"

    expect(page).to have_content("Market Service Payments")
  end

  it "shows the active markets" do
    visit "/admin/financials/admin/service_payments"

    within("#service-payments") do
      expect(page).to have_content(unconfigured_market.name)
      expect(page).to have_content(configured_market.name)
      expect(page).not_to have_content(deactivated_market.name)
    end
  end

  it "allows a payment to be run for a configured market" do
    visit "/admin/financials/admin/service_payments"

    within("#market_#{configured_market.id}") do
      expect(page).to have_button(payment_button_text)
    end
  end

  it "does not allow a payment to be run for an unconfigured market" do
    visit "/admin/financials/admin/service_payments"

    within("#market_#{unconfigured_market.id}") do
      expect(page).not_to have_button(payment_button_text)
    end
  end

  it "runs a service payment through balanced", :vcr do
    market_manager = create(:user, managed_markets: [configured_market])

    visit "/admin/financials/admin/service_payments"

    expect(page.find("#market_#{configured_market.id} .next-payment-date").text).to eq(1.day.ago.strftime("%m/%d/%Y"))

    click_button payment_button_text

    expect(page).to have_content("Payment made for #{configured_market.name}")
    expect(page.find("#market_#{configured_market.id} .next-payment-date").text).to eq(1.month.from_now(1.day.ago).strftime("%m/%d/%Y"))

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    open_last_email
    expect(current_email).to be_delivered_to(market_manager.email)
  end
end
