require "spec_helper"

feature "Opening and closing a market:" do
  let!(:seller)         { create(:organization, :seller, :single_location) }
  let!(:buyer)          { create(:organization, :buyer, :single_location) }
  let!(:products)       { create_list(:product, 5, :sellable, organization: seller) }
  let!(:market)         { create(:market, :with_addresses, :with_delivery_schedule, organizations: [buyer,seller]) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

  context "when a market is open" do

    scenario "a market manager can close a market but still shop" do
      switch_to_subdomain market.subdomain
      sign_in_as(market_manager)

      click_link "Market Admin"
      click_link "Markets"
      click_link market.name

      expect(find_field("This market is open")).to be_checked

      uncheck "This market is open"
      click_button "Update Market"

      expect(find_field("This market is open")).not_to be_checked

      click_link "Order", match: :first
      expect(page).not_to have_content("The Market Is Currently Closed")
      expect(page).to have_content("Select a Buyer")
    end
  end

  context "when the market is already closed" do
    scenario "a market manager can open a market" do
      switch_to_subdomain market.subdomain
      sign_in_as(market_manager)

      click_link "Market Admin"
      click_link "Markets"
      click_link market.name

      check "This market is open"
      click_button "Update Market"

      click_link "Order", match: :first
      expect(page).not_to have_content("The Market Is Currently Closed")
      expect(page).to have_content("Select a Buyer")
    end
  end
end
