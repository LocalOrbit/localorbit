require "spec_helper"

feature "viewing and managing users" do
  let!(:admin) { create(:user, :admin) }
  let!(:market_manager) { create(:user, :market_manager) }
  let(:market) { market_manager.markets.first }

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
  
  context "as a user" do
    before do
      switch_to_subdomain(market_manager.markets.first.subdomain)
      sign_in_as(market_manager)
    end

    scenario "viewing only relevant users" do
      visit "/admin/users"
      within "h1" do
        expect(page).to have_content('Users')
      end
      expect(page).to have_content(market_manager.name)
      expect(page).to have_content(market_manager.email)
      expect(page).to have_content(market.name)
      expect(page).not_to have_content(admin.email)
    end
  end
end
