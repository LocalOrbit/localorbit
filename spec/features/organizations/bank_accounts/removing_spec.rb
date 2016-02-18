require "spec_helper"

feature "Adding a bank account to an organization" do
  let!(:market)    { create(:market) }
  let!(:org)        { create(:organization, :buyer, can_sell: true, markets: [market]) }
  let!(:member)     { create(:user, :buyer, organizations: [org]) }
  let!(:non_member) { create(:user, :buyer) }

  let!(:account)    { create(:bank_account, :checking, name: "Org Bank Account", bankable: org) }

  context "as an organization member" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(member)

      visit admin_organization_bank_accounts_path(org)
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

      visit admin_organization_bank_accounts_path(org)

      expect(page).to have_content("We can't find that page.")
      expect(page.status_code).to eq(404)
    end
  end
end
