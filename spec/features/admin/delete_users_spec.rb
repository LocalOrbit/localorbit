require "spec_helper"

describe "Deleting a user", :js do
  let(:market_manager) { create(:user, :market_manager) }
  let(:market) { market_manager.managed_markets.first }
  let!(:org) { create(:organization, markets: [market]) }
  let!(:user) { create(:user, organizations: [org]) }
  let!(:user2) { create(:user, organizations: [org]) }

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

      expect(page).to have_content("Successfully removed #{user.email}.")
      expect(Dom::Admin::UserRow.find_by_email(user.email)).to be_nil
    end
  end

  describe "as an organization member" do
    it "removes a user from an organization" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)

      sleep 10

      click_link "Account"
      click_link "Your Organization"
      click_link "Users"

      user_row = Dom::Admin::UserRow.find_by_email(user2.email)
      user_row.remove!

      expect(page).to have_content("Successfully removed #{user2.email}.")
      expect(Dom::Admin::UserRow.find_by_email(user2.email)).to be_nil
    end
  end
end
