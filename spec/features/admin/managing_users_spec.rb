require "spec_helper"

feature "viewing and managing users" do
  let!(:admin) { create(:user, :admin) }
  let!(:market) { create(:market, name: 'Test Market') }
  let!(:market_manager) { create(:user, managed_markets:[market]) }

  let!(:organization) {  create(:organization, name: 'Test Org 1', markets: [market])}
  let!(:organization2) {  create(:organization, name: 'Test Org 2', markets: [market])}
  let!(:user) { create(:user, organizations: [organization, organization2]) }

  context "as an admin" do
    before do
      switch_to_main_domain
      sign_in_as(admin)
    end

    scenario "getting there" do
      click_link "Market Admin"
      click_link "All Users"
      within "h1" do
        expect(page).to have_content('Users')
      end
    end

    scenario "viewing all users" do
      visit "/admin/users"
      within "h1" do
        expect(page).to have_content('Users')
      end
      expect(page).to have_content(market_manager.name)
      expect(page).to have_content(market_manager.email)
      expect(page).to have_content(admin.name)
      expect(page).to have_content(admin.email)
      expect(page).to have_content(market.name)
    end
  end

  context "as a market manager" do
    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)
    end

    scenario "viewing only relevant users" do
      visit admin_users_path
      within "h1" do
        expect(page).to have_content('Users')
      end

      manager_row = Dom::Admin::UserRow.find_by_email(market_manager.email)
      user_row = Dom::Admin::UserRow.find_by_email(user.email)

      expect(manager_row.affiliations).to eql("Test Market, Market Manager")
      expect(user_row.affiliations).to eql("Test Market: Test Org 1, Seller Test Market: Test Org 2, Seller")
    end

    scenario "viewing only relevant users after deleting an organization" do
      delete_organization(organization)
      visit admin_users_path

      within "h1" do
        expect(page).to have_content('Users')
      end

      manager_row = Dom::Admin::UserRow.find_by_email(market_manager.email)
      user_row = Dom::Admin::UserRow.find_by_email(user.email)

      expect(manager_row.affiliations).to eql("Test Market, Market Manager")
      expect(user_row.affiliations).to eql("Test Market: Test Org 2, Seller")
    end
  end
end
