require "spec_helper"

feature "Removing a credit card from a market" do
  let!(:market)          { create(:market) }
  let!(:market_manager)  { create(:user, :market_manager, managed_markets: [market]) }
  let!(:non_member)      { create(:user, :market_manager) }

  let!(:account)         { create(:bank_account, :credit_card, name: "Org Bank Account", bankable: market) }

  context "as an market manager" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)

      visit admin_market_bank_accounts_path(market)
    end

    scenario "successfully removing a bank account" do
      credit_card = Dom::BankAccount.first
      expect(credit_card.bank_name).to eq("Visa")
      expect(credit_card.name).to eq("Org Bank Account")
      expect(credit_card.account_number).to eq("**** **** **** #{account.last_four}")
      expect(credit_card.account_type).to eq("Credit Card")
      expect(credit_card.notes).to eq("")

      credit_card.click_remove_link

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
