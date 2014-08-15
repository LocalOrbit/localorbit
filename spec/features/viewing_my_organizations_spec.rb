require "spec_helper"

feature "user viewing their organizations" do
  let!(:market1) { create(:market) }
  let!(:org1) { create(:organization, markets: [market1]) }
  let!(:org2) { create(:organization, markets: [market1]) }
  let!(:org3) { create(:organization, markets: [market1]) }
  let!(:user) { create(:user, organizations: [org1, org2]) }

  context "as a user" do

    before do
      u = user.user_organizations.find_by(organization: org1)
      u.update_attributes(enabled: false)
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
    end

    scenario "I can not view activity on organizations when im a suspended user" do
      click_link "Account"
      click_link "Your Organization"

      expect(page).to have_content(org1.name)
      expect(page).to have_content(org2.name)

      expect(page).to_not have_content(org3.name)

      expect(page).to_not have_link(org1.name)
    end
  end

  context "as a market manager" do

    before do
      switch_to_subdomain(market1.subdomain)
      sign_in_as(user)
    end

    scenario "I can view the organizations I am directly linked to" do
      click_link "Account"
      click_link "Your Organization"

      expect(page).to have_content(org1.name)
      expect(page).to have_content(org2.name)

      expect(page).not_to have_content(org3.name)
    end
  end
end
