require "spec_helper"

describe "Viewing an empty cart" do
  let(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
  let(:market) { create(:market, :with_addresses, organizations: [buyer], alternative_order_page: false) }
  let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }
  let!(:delivery) { create(:delivery_schedule, market: market) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  context "as a buyer" do
    it "shows the cart", js: true do
      sign_in_as(user)
      expect(Dom::CartLink.first.node).to have_content("0")
      click_link "Cart", match: :first
      expect(page).to have_content("Your cart is empty.")
      expect(page).to have_content("Please add items to your cart to see them here and make a purchase.")
    end
  end

  context "as a market manager", js: true  do
    it "shows the cart" do
      sign_in_as(market_manager)
      expect(Dom::CartLink.first.node).to have_content("0")
      click_link "Cart"
      expect(page).to have_content("Your cart is empty.")
      expect(page).to have_content("Please add items to your cart to see them here and make a purchase.")
    end
  end

  it "prevents a user from checking out without cart items" do
    sign_in_as(user)
    visit "/cart"

    expect(page).to have_content("Your cart is empty. Please add items to your cart before checking out.")
  end
end
