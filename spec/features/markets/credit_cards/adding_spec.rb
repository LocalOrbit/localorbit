require "spec_helper"

feature "Adding credit card to a market", :js, :vcr do
  # TODO: use payment_provider constants
  let!(:market)         { create(:market, name: "Fake Market", payment_provider: 'balanced') }
  let!(:admin)          { create(:user, :admin) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }
  let!(:org)            { create(:organization, name: "Fake Organization", markets: [market]) }
  let!(:member)         { create(:user, organizations: [org]) }
  let!(:non_member)     { create(:user) }

  before do
    CreateBalancedCustomerForEntity.perform(market: market)
  end

  scenario "as a market manager" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)

    visit new_admin_market_bank_account_path(market)

    select "Credit Card", from: "balanced_account_type"
    fill_in "Name", with: "John Doe"
    fill_in "Card Number", with: "5105105105105100"
    fill_in "Security Code", with: "123"
    select "5", from: "expiration_month"
    select "2020", from: "expiration_year"

    expect(page).not_to have_content("EIN")
    expect(page).not_to have_content("Full Legal Name")

    click_button "Save"

    expect(page).to have_content("Successfully added a payment method")

    bank_account = Dom::BankAccount.first
    expect(bank_account.bank_name).to eq("MasterCard")
    expect(bank_account.name).to eq("John Doe")
    expect(bank_account.account_number).to eq("**** **** **** 5100")
    expect(bank_account.account_type).to eq("Credit Card")
    expect(bank_account.expiration).to eq("Expires 05/2020")
  end
end
