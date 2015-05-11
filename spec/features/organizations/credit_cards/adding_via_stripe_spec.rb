require "spec_helper"

feature "Adding a credit card to an organization", :js, :vcr do
  let(:payment_provider) { PaymentProvider::Stripe.id }
  let!(:market)         { create(:market, name: "Fake Market", payment_provider: payment_provider) }
  let!(:org)            { create(:organization, name: "Fake Organization", markets: [market]) }
  let!(:member)         { create(:user, organizations: [org]) }

  context "as an organization member" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(member)

      visit new_admin_organization_bank_account_path(org)
    end

    scenario "successfully adding a credit card" do
      select "Credit Card", from: "provider_account_type"
      fill_in "Name", with: "John Doe"
      fill_in "Card Number", with: "5105105105105100"
      fill_in "Security Code", with: "123"
      select "5", from: "expiration_month"
      select "2020", from: "expiration_year"
      fill_in "Notes", with: "primary"

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
      expect(bank_account.notes).to eq("primary")
    end

    scenario "failing to enter a valid card number" do
      click_button "Save"

      expect(page).not_to have_content("Successfully added a credit card")
      expect(page).to have_content("Account type: Please select an account type.")

      select "Credit Card", from: "provider_account_type"
      fill_in "Card Number", with: "5105105105105"
      fill_in "Security Code", with: "123"
      select "5", from: "expiration_month"
      select "2020", from: "expiration_year"

      click_button "Save"
      expect(page).not_to have_content("Successfully added a payment method")
      expect(page).to have_css(".field_with_errors")
      expect(page).to have_content("is not a valid credit card number")
    end

    scenario "duplicate credit card gives an error" do
      create(:bank_account, :credit_card, name: "John Doe", bank_name: "MasterCard", account_type: "mastercard", last_four: "5100", bankable: org)

      select "Credit Card", from: "provider_account_type"
      fill_in "Name", with: "John Doe"
      fill_in "Card Number", with: "5105105105105100"
      fill_in "Security Code", with: "123"
      select "12", from: "expiration_month"
      select "2020", from: "expiration_year"

      click_button "Save"

      expect(page).to have_content("Unable to save payment method")
      expect(page).to have_content("Payment method already exists for this organization")
    end
  end

  context "as a buyer" do
    let!(:org) { create(:organization, :buyer, name: "Fake Organization", markets: [market]) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(member)

      visit new_admin_organization_bank_account_path(org)
    end

    scenario "successfully adding a credit card" do
      select "Credit Card", from: "provider_account_type"
      fill_in "Name", with: "John Doe"
      fill_in "Card Number", with: "5105105105105100"
      fill_in "Security Code", with: "123"
      select "5", from: "expiration_month"
      select "2020", from: "expiration_year"
      fill_in "Notes", with: "primary"

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
      expect(bank_account.notes).to eq("primary")
    end
  end
end
