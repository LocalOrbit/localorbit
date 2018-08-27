require "spec_helper"

describe "Deleting a user", :js do
  let(:market_manager) { create(:user, :market_manager) }
  let(:market) { market_manager.managed_markets.first }
  let!(:org) { create(:organization, :buyer, markets: [market]) }
  let!(:user) { create(:user, :buyer, organizations: [org]) }
  let!(:user2) { create(:user, :buyer, organizations: [org]) }

  describe "as a market manager" do
    it "removes a user from an organization" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(market_manager)

      click_link "Market Admin"
      click_link "Organizations"

      click_link org.name
      click_link "Users"

      user_row = Dom::Admin::UserRow.find_by_email(user.email)
      user_row.remove!
      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content("Successfully removed #{user.email}.")
      expect(Dom::Admin::UserRow.find_by_email(user.email)).to be_nil
    end
  end

  describe "as an organization member" do
    it "removes a user from an organization" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)

      click_link "Account"
      click_link "Your Organization"
      click_link "Users"

      user_row = Dom::Admin::UserRow.find_by_email(user2.email)
      user_row.remove!
      page.driver.browser.switch_to.alert.accept

      expect(page).to have_content("Successfully removed #{user2.email}.")
      expect(Dom::Admin::UserRow.find_by_email(user2.email)).to be_nil
    end
  end
end
