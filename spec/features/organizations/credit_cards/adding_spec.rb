require "spec_helper"

feature "Adding a credit card to an organization", :js, :vcr do
  let!(:market_manager) { create(:user, :market_manager) }
  let!(:market) { market_manager.managed_markets.first }
  let(:org) { create(:organization, markets: [market]) }
  let(:member) { create(:user, organizations: [org]) }
  let(:non_member) { create(:user) }

  before do
    CreateBalancedCustomerForEntity.perform(organization: org)
  end

  context "as a market manager" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)

      visit new_admin_organization_bank_account_path(org)
    end

    scenario "successfully adding a credit card" do
      select "Credit Card", from: "balanced_account_type"
      fill_in "Name", with: "John Doe"
      fill_in "Card Number", with: "5105105105105100"
      fill_in "Security Code", with: "123"
      select "5", from: "expiration_month"
      select "2014", from: "expiration_year"
      fill_in "Notes", with: "primary"

      fill_in "Organization EIN", with: "20-1234567"
      fill_in "Full Legal Name", with: "John Patrick Doe"
      select "Sep", from: "representative_dob_month"
      select "17", from: "representative_dob_day"
      select "1990", from: "representative_dob_year"

      fill_in "Last 4 of SSN", with: "1234"
      fill_in "Street Address (Personal)", with: "6789 Fake Dr"
      fill_in "Zip Code (Personal)", with: "12345"

      click_button "Save"

      expect(page).to have_content("Successfully added a payment method")

      bank_account = Dom::BankAccount.first
      expect(bank_account.bank_name).to eq("MasterCard")
      expect(bank_account.name).to eq("John Doe")
      expect(bank_account.account_number).to eq("**** **** **** 5100")
      expect(bank_account.account_type).to eq("Credit Card")
      expect(bank_account.expiration).to eq("Expires 05/2014")
      expect(bank_account.notes).to eq("primary")
    end

    scenario "failing to enter a valid card number" do
      click_button "Save"

      expect(page).not_to have_content("Successfully added a credit card")
      expect(page).to have_content("Account type: Please select an account type.")

      select "Credit Card", from: "balanced_account_type"
      fill_in "Card Number", with: "5105105105105"
      fill_in "Security Code", with: "123"
      select "5", from: "expiration_month"
      select "2014", from: "expiration_year"

      click_button "Save"
      expect(page).not_to have_content("Successfully added a payment method")
      expect(page).to have_css(".field_with_errors")
      expect(page).to have_content("is not a valid credit card number")
    end
  end

  context "as an organization member" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(member)

      visit new_admin_organization_bank_account_path(org)
    end

    scenario "successfully adding a credit card" do
      select "Credit Card", from: "balanced_account_type"
      fill_in "Name", with: "John Doe"
      fill_in "Card Number", with: "5105105105105100"
      fill_in "Security Code", with: "123"
      select "5", from: "expiration_month"
      select "2014", from: "expiration_year"
      fill_in "Notes", with: "primary"

      fill_in "Organization EIN", with: "20-1234567"
      fill_in "Full Legal Name", with: "John Patrick Doe"
      select "Sep", from: "representative_dob_month"
      select "17", from: "representative_dob_day"
      select "1990", from: "representative_dob_year"

      fill_in "Last 4 of SSN", with: "1234"
      fill_in "Street Address (Personal)", with: "6789 Fake Dr"
      fill_in "Zip Code (Personal)", with: "12345"

      click_button "Save"

      expect(page).to have_content("Successfully added a payment method")

      bank_account = Dom::BankAccount.first
      expect(bank_account.bank_name).to eq("MasterCard")
      expect(bank_account.name).to eq("John Doe")
      expect(bank_account.account_number).to eq("**** **** **** 5100")
      expect(bank_account.account_type).to eq("Credit Card")
      expect(bank_account.expiration).to eq("Expires 05/2014")
      expect(bank_account.notes).to eq("primary")
    end
  end

  context "as a non member" do
    scenario "I cannot see the page" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(non_member)

      visit new_admin_organization_bank_account_path(org)

      expect(page).to have_content("The page you were looking for doesn't exist.")
      expect(page.status_code).to eq(404)
    end
  end
end
