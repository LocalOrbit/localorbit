require "spec_helper"

feature "user viewing their organizations" do
  let!(:market) { create(:market, organizations: [product.organization]) }
  let!(:org1) { create(:organization, markets: [market]) }
  let!(:org2) { create(:organization, active: false, markets: [market]) }
  let!(:org3) { create(:organization, markets: [market]) }
  let(:user) { create(:user, organizations: [org1, org2]) }

  let!(:org1_product) { create(:product, name: "Canned Pears", organization: org1) }
  let!(:org2_product) { create(:product, name: "Bananas", organization: org2) }

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

    scenario "Products from deactivated organizations don't show in products" do
      click_link "Account"
      click_link "Your Organization"
      expect(page).to_not have_content("Activate")
      click_link "Deactivate"

      expect(page).to_not have_content("Deactivate")

    end

    scenario "I can not see activity on my deactivated organizations" do
      click_link "Account"
      click_link "Your Organization"

      click_link "Products"
    end

  end

  context "as a market manager" do
    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)

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