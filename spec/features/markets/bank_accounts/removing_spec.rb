require "spec_helper"

feature "Removing a bank account to a market" do
  let!(:market)         { create(:market) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }
  let!(:non_member)     { create(:user) }

  let!(:account)        { create(:bank_account, :checking, name: "Org Bank Account", bankable: market) }

  context "as an organization member" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)

      visit admin_market_bank_accounts_path(market)
    end

    scenario "successfully removing a bank account" do
      bank_account = Dom::BankAccount.first
      expect(bank_account.bank_name).to eq("LMCU")
      expect(bank_account.name).to eq("Org Bank Account")
      expect(bank_account.account_number).to eq("******#{account.last_four}")
      expect(bank_account.account_type).to eq("Checking")
      expect(bank_account.notes).to eq("")

      bank_account.click_remove_link

      expect(page).to have_content("Successfully removed payment method")
      expect(Dom::BankAccount.count).to eql(0)
    end
  end

  context "as a non member" do
    scenario "I cannot see the page" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(non_member)

      visit admin_market_bank_accounts_path(market)

      expect(page).to have_content("We can't find that page.")
      expect(page.status_code).to eq(404)
    end
  end
end
