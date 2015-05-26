require "spec_helper"

feature "Verifying a bank account", :js, :vcr do
  let!(:market_manager) { create(:user, :admin, :market_manager) }
  let!(:market) { market_manager.managed_markets.first }
  let!(:org) { create(:organization, markets: [market]) }

  context "as a market manager" do
    before do
      CreateBalancedCustomerForEntity.perform(organization: org)
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)

      bank_account = Balanced::BankAccount.new(
        routing_number: "021000021",
        account_number: "9900000002",
        name: "Johann Bernoulli",
        type: "checking"
      )
      bank_account.save

      AddBalancedBankAccountToEntity.perform(
        entity: org,
        bank_account_params: {
          name: "Org Bank Account",
          last_four: "0002",
          balanced_uri: bank_account.uri,
          account_type: "checking"
        },
        representative_params: {}
      )

      visit admin_organization_bank_accounts_path(org)

      click_link "Verify"
    end

    scenario "successfully verifying an account" do
      fill_in "Amount 1", with: 1
      fill_in "Amount 2", with: 1

      click_button "Verify"

      expect(page).to have_content("Payment Methods")
      expect(Dom::BankAccount.first).to be_verfied
    end

    scenario "unsuccessfully verifying an account" do
      fill_in "Amount 1", with: 2
      fill_in "Amount 2", with: 3

      click_button "Verify"

      expect(page).to have_content("Verify Your Account")
    end

    scenario "failing verification on an account" do
      fill_in "Amount 1", with: 2
      fill_in "Amount 2", with: 3

      click_button "Verify"

      fill_in "Amount 1", with: 2
      fill_in "Amount 2", with: 3

      click_button "Verify"

      fill_in "Amount 1", with: 2
      fill_in "Amount 2", with: 3

      click_button "Verify"

      expect(page).to have_content("Bank account verification failed")
    end
  end
end
