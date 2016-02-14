require "spec_helper"

feature "Removing a credit card from an organization" do
  let!(:market)    { create(:market) }
  let!(:org)        { create(:organization, can_sell: true, markets: [market]) }
  let!(:member)     { create(:user, :buyer, organizations: [org]) }
  let!(:non_member) { create(:user) }

  let!(:account)    { create(:bank_account, :credit_card, name: "Org Bank Account", bankable: org) }

  context "as an organization member" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(member)

      visit admin_organization_bank_accounts_path(org)
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

      visit admin_organization_bank_accounts_path(org)

      expect(page).to have_content("We can't find that page.")
      expect(page.status_code).to eq(404)
    end
  end
end
