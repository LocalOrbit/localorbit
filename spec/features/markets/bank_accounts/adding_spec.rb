require "spec_helper"

feature "Adding bank account to a market", :js, :shaky do
  let!(:market) { create(:market, name: "Marketville") }
  let(:org)     { create(:organization, markets: [market]) }

  before :all do
    VCR.turn_off!
  end

  after :all do
    VCR.turn_on!
  end

  before do
    CreateBalancedCustomerForEntity.perform(market: market)
  end

  scenario "as an admin" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(create(:user, :admin))

    visit new_admin_market_bank_account_path(market)

    select "Checking", from: "provider_account_type"

    fill_in "EIN", with: "20-1234567"
    fill_in "Full Legal Name", with: "John Patrick Doe"
    select "Sep", from: "representative_dob_month"
    select "17", from: "representative_dob_day"
    select "1990", from: "representative_dob_year"

    fill_in "Last 4 of SSN", with: "1234"
    fill_in "Street Address (Personal)", with: "6789 Fake Dr"
    fill_in "Zip Code (Personal)", with: "12345"

    fill_in "Name", with: "Market Bank Account"
    select("Checking", from: "Account Type")
    fill_in "Routing Number", with: "021000021"
    fill_in "Account Number", with: "9900000002"

    click_button "Save"

    expect(page).to have_content("Successfully added a payment method")

    bank_account = Dom::BankAccount.first
    expect(bank_account.bank_name).to eq("JPMORGAN CHASE BANK")
    expect(bank_account.name).to eq("Market Bank Account")
    expect(bank_account.account_number).to eq("******0002")
    expect(bank_account.account_type).to eq("Checking")

    expect(market.reload).to be_balanced_underwritten
  end

  scenario "as a market manager" do
    switch_to_subdomain(market.subdomain)
    sign_in_as(create(:user, managed_markets: [market]))

    visit new_admin_market_bank_account_path(market)

    select "Checking", from: "provider_account_type"

    fill_in "EIN", with: "20-1234567"
    fill_in "Full Legal Name", with: "John Patrick Doe"
    select "Sep", from: "representative_dob_month"
    select "17", from: "representative_dob_day"
    select "1990", from: "representative_dob_year"

    fill_in "Last 4 of SSN", with: "1234"
    fill_in "Street Address (Personal)", with: "6789 Fake Dr"
    fill_in "Zip Code (Personal)", with: "12345"

    fill_in "Name", with: "Market Bank Account"
    select("Checking", from: "Account Type")
    fill_in "Routing Number", with: "021000021"
    fill_in "Account Number", with: "9900000002"

    click_button "Save"

    expect(page).to have_content("Successfully added a payment method")

    bank_account = Dom::BankAccount.first
    expect(bank_account.bank_name).to eq("JPMORGAN CHASE BANK")
    expect(bank_account.name).to eq("Market Bank Account")
    expect(bank_account.account_number).to eq("******0002")
    expect(bank_account.account_type).to eq("Checking")

    expect(market.reload).to be_balanced_underwritten
  end
end
