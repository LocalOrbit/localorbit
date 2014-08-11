require "spec_helper"

feature "Buying in a closed market" do
  before do
    Timecop.travel(Date.parse("2014-06-16"))
  end

  after do
    Timecop.return
  end

  let!(:market)   { create(:market, :with_addresses, :with_delivery_schedule, closed: true) }
  let!(:seller)   { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:buyer)    { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:products) { create_list(:product, 5, :sellable, organization: seller) }
  let!(:user)     { create(:user, organizations: [buyer]) }

  context "market has one delivery schedule" do
    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)
    end

    scenario "Buyer visits the shop page" do
      expect(page).to have_content("The Market Is Currently Closed")
    end

    scenario "Buyer visits the sellers page" do
      click_link "Sellers", match: :first

      expect(page).to have_content("Who")
      expect(page).to have_content("When")
      expect(page).to have_content("Where")
      expect(page).not_to have_content("Currently Selling")
      expect(page).not_to have_content("Quantity")
    end
  end

  context "market has multiple delivery schedules" do
    let!(:delivery_schedule){ create(:delivery_schedule, market: market) }

    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)
    end

    scenario "Buyer visits the shop page" do
      expect(page).to have_content("The Market Is Currently Closed")
    end

    scenario "Buyer visits the sellers page" do
      click_link "Sellers", match: :first

      choose_delivery "Delivery: Tuesday June 17, 2014 Between 7:00AM and 11:00AM"

      expect(page).to have_content("Who")
      expect(page).to have_content("When")
      expect(page).to have_content("Where")
      expect(page).not_to have_content("Currently Selling")
      expect(page).not_to have_content("Quantity")
    end
  end

  context "Market starts as open" do
    let!(:market)   { create(:market, :with_addresses, :with_delivery_schedule, closed: false) }

    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)
    end

    scenario "Buyer begins shopping, the market manager closes the market, then the buyer checks out", :js do
      item = Dom::Cart::Item.find_by_name(products[0].name)
      item.set_quantity(12)
      expect(page).to have_content("Added to cart!")

      market_copy = Market.find(market.id)
      market_copy.closed = true
      market_copy.save!

      Dom::CartLink.first.node.click
      expect(page).to have_content("The Market Is Currently Closed")
    end
  end
end
