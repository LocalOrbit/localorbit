require "spec_helper"

describe "Viewing an empty cart" do
  let(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
  let(:market) { create(:market, :with_addresses, organizations: [buyer]) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }
  let!(:delivery) { create(:delivery_schedule, market: market) }

  context "as a buyer" do
    it "shows the cart" do
      sign_in_as(user)
      switch_to_subdomain(market.subdomain)
      expect(Dom::CartLink.first.node).to have_content("0")
      click_link "Cart", match: :first
      within "h1" do
        expect(page).to have_content("Cart")
      end
    end
  end

  context "as a market manager" do
    it "shows the cart" do
      sign_in_as(market_manager)
      switch_to_subdomain(market.subdomain)
      expect(Dom::CartLink.first.node).to have_content("0")
      click_link "Cart"
      within "h1" do
        expect(page).to have_content("Cart")
      end
    end
  end

end
