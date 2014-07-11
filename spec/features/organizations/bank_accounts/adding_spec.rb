require "spec_helper"

feature "Adding a bank account to an organization", js: true do
  let!(:admin) { create(:user, :admin) }
  let!(:market_manager) { create(:user, :market_manager) }
  let!(:market) { market_manager.managed_markets.first }
  let(:org) { create(:organization, can_sell: true, markets: [market]) }
  let(:member) { create(:user, organizations: [org]) }
  let(:non_member) { create(:user) }

  before :all do
    VCR.turn_off!
  end

  after :all do
    VCR.turn_on!
  end

  before do
    CreateBalancedCustomerForEntity.perform(organization: org)
  end

  context "as an organization member" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(member)

      visit new_admin_organization_bank_account_path(org)
    end

    scenario "successfully adding a bank account" do
      select "Checking", from: "balanced_account_type"

      fill_in "Organization EIN", with: "20-1234567"
      fill_in "Full Legal Name", with: "John Patrick Doe"
      select "Sep", from: "representative_dob_month"
      select "17", from: "representative_dob_day"
      select "1990", from: "representative_dob_year"

      fill_in "Last 4 of SSN", with: "1234"
      fill_in "Street Address (Personal)", with: "6789 Fake Dr"
      fill_in "Zip Code (Personal)", with: "12345"

      fill_in "Name", with: "Org Bank Account"
      select("Checking", from: "Account Type")
      fill_in "Routing Number", with: "021000021"
      fill_in "Account Number", with: "9900000002"
      fill_in "Notes", with: "primary"

      click_button "Save"

      expect(page).to have_content("Successfully added a payment method")

      bank_account = Dom::BankAccount.first
      expect(bank_account.bank_name).to eq("JPMORGAN CHASE BANK")
      expect(bank_account.name).to eq("Org Bank Account")
      expect(bank_account.account_number).to eq("******0002")
      expect(bank_account.account_type).to eq("Checking")
      expect(bank_account.notes).to eq("primary")

      expect(org.reload).to be_balanced_underwritten
    end

    scenario "failing to enter a valid account" do
      click_button "Save"
      expect(page).not_to have_content("Successfully added a payment method")
      expect(page).to have_content("Account type: Please select an account type.")

      select "Checking", from: "balanced_account_type"

      fill_in "Name", with: "Org Bank Account"
      select("Checking", from: "Account Type")
      fill_in "Routing Number", with: "100000007"
      fill_in "Account Number", with: "8887776665555"

      click_button "Save"

      expect(page).not_to have_content("Successfully added a payment method")
      expect(page).to have_css(".field_with_errors")
      expect(page).to have_content("Routing number is invalid.")
    end

    scenario "duplicate bank account gives an error" do
      create(:bank_account, :checking, bank_name: 'JPMORGAN CHASE BANK', name: 'Org Bank Account', last_four: '0002', bankable: org)

      fill_in "Name", with: "Org Bank Account"
      select("Checking", from: "Account Type")
      fill_in "Routing Number", with: "021000021"
      fill_in "Account Number", with: "9900000002"
      fill_in "Notes", with: "primary"

      click_button "Save"

      expect(page).to have_content("Unable to save payment method")
      expect(page).to have_content("Payment method already exists for this organization")
    end
  end
end
