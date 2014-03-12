require "spec_helper"

feature "Adding a bank account to an organization", js: true, vcr: {cassette_name: "create_balanced_customer_add_bank_account"} do
  let!(:market_manager) { create(:user, :admin, :market_manager) }
  let!(:market) { market_manager.managed_markets.first }
  let!(:org) { create(:organization, markets: [market]) }
  let!(:member) { create(:user, :admin, organizations: [org]) }

  before do
    CreateBalancedCustomerForOrganization.perform(organization: org)
  end

  scenario "as a market manager" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(market_manager)

    visit new_admin_organization_bank_account_path(org)

    fill_in "Account Name", with: "Org Bank Account"
    choose "Checking"
    fill_in "Routing Number", with: "021000021"
    fill_in "Account Number", with: "9900000002"

    click_button "Save"
    sleep 4

    bank_account = Dom::BankAccount.first
    expect(bank_account.bank_name).to eq("JPMORGAN CHASE BANK")
    expect(bank_account.account_number).to eq("******0002")
    expect(bank_account.account_type).to eq("checking")
  end

  scenario "as an organization member"
end
