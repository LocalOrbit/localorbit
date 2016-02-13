require "spec_helper"

describe "Admin Managing Market Managers" do
  let(:market) { create(:market) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  describe "as a normal user" do
    let!(:normal_user) { create(:user) }
    let!(:org) { create(:organization, markets: [market], users: [normal_user]) }

    it "I can not manage market managers" do
      sign_in_as normal_user

      visit admin_market_managers_path(market)

      expect(page).to have_text("page you were looking for doesn't exist")
    end
  end

  describe "as a market manager" do
    let(:user) { create(:user, :market_manager, managed_markets: [market]) }

    before do
      sign_in_as user
    end

    it "I can see the current market managers" do
      visit "/admin/markets/#{market.id}"

      click_link "Managers"

      within(".market-managers") do
        expect(page).to have_text(user.email)
      end
    end

    it "I can add a market manager by email" do
      visit "/admin/markets/#{market.id}/managers"

      fill_in "email", with: "new-user@example.com"
      click_button "Add Market Manager"

      expect(page).to have_text("new-user@example.com")

      open_email("new-user@example.com")
      expect(current_email.body).to have_content("You have been invited")
      expect(current_email.body).to have_content(market.name)
    end

    it "requries an email address to invite" do
      visit "/admin/markets/#{market.id}/managers"

      fill_in "email", with: ""
      click_button "Add Market Manager"

      expect(page).to have_text("Email address is required.")
    end
  end

  describe "as an admin" do
    let(:user) { create(:user, :admin) }
    let(:user2) { create(:user, :market_manager) }

    before(:each) do
      sign_in_as user

      user2.managed_markets << market
    end

    it "I can see the current market managers" do
      visit "/admin/markets/#{market.id}"

      click_link "Managers"

      expect(page).to have_text(user2.email)
    end

    it "I can add a market manager by email" do
      visit "/admin/markets/#{market.id}/managers"

      fill_in "email", with: "new-user@example.com"
      click_button "Add Market Manager"

      expect(page).to have_text("new-user@example.com")

      click_link "Sign Out"

      open_last_email

      visit_in_email("Join #{market.name}")

      expect(page).to have_content("Set up your account")
    end

    it "requries an email address to invite" do
      visit "/admin/markets/#{market.id}/managers"

      fill_in "email", with: ""
      click_button "Add Market Manager"

      expect(page).to have_text("Email address is required.")
    end

    it "I can remove a current market manager", :js do
      visit "/admin/markets/#{market.id}/managers"

      expect(page).to have_text(user2.email)

      manager_row = Dom::Admin::UserRow.find_by_email(user2.email)
      manager_row.remove!

      expect(page).to_not have_text(user2.email)
    end
  end
end
