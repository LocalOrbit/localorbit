require "spec_helper"

feature "user viewing their organizations" do
  let!(:market) { create(:market) }
  let!(:org1) { create(:organization, markets: [market]) }
  let!(:org2) { create(:organization, markets: [market]) }
  let!(:org3) { create(:organization, markets: [market]) }
  let(:user) { create(:user, organizations: [org1, org2]) }
  let(:market_manager) { create(:user, :market_manager, managed_markets: [market], organizations: [org1])}

  context "as a user" do
    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)
    end

    scenario "I can view my organizations" do
      click_link "Account"
      click_link "Your Organization"
      expect(page).to have_content(org1.name)
      expect(page).to have_content(org2.name)
      expect(page).not_to have_content(org3.name)
    end
  end

  context "as a market manager" do
    before do
      switch_to_subdomain market.subdomain
      sign_in_as(market_manager)
    end

    scenario "I can view the organizations I am directly linked to" do
      click_link "Account"
      click_link "Your Organization"
      expect(page).to have_content(org1.name)
      expect(page).not_to have_content(org2.name)
      expect(page).not_to have_content(org3.name)
    end
  end
end