require "spec_helper"

feature "When a Market is closed" do
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
  let!(:user)     { create(:user, :buyer, organizations: [buyer]) }

  context "and has one delivery schedule" do
    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)
    end

    scenario "the Buyer cannot Shop" do
      expect(page).to have_content("The Market Is Currently Closed")
    end

    scenario "the Sellers will not display products" do
      click_link "Sellers", match: :first

      expect(page).to have_content("Who")
      expect(page).to have_content("When")
      expect(page).to have_content("Where")
      expect(page).not_to have_content("Currently Selling")
      expect(page).not_to have_content("Quantity")
    end

    context "when Buyer has placed an order" do
      let!(:delivery_schedule) { create(:delivery_schedule) }
      let!(:delivery)    { delivery_schedule.next_delivery }
      let!(:order_item1) { create(:order_item, product: products[0]) }
      let!(:order1)      { create(:order, delivery: delivery, items: [order_item1], organization: buyer) }

      scenario "the Buyer may view her Orders" do
        click_link "Purchase History"
        follow_buyer_order_link order: order1
      end
    end
  end

  context "an has multiple delivery schedules" do
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }

    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)
    end

    scenario "the Buyer cannot Shop" do
      expect(page).to have_content("The Market Is Currently Closed")
    end

    scenario "the Sellers don't display products" do
      click_link "Sellers", match: :first

      choose_delivery "Delivery: Tuesday June 17, 2014 Between 7:00AM and 11:00AM"

      expect(page).to have_content("Who")
      expect(page).to have_content("When")
      expect(page).to have_content("Where")
      expect(page).not_to have_content("Currently Selling")
      expect(page).not_to have_content("Quantity")
    end
  end

  context "given that the Market starts as open" do
    let!(:market)   { create(:market, :with_addresses, :with_delivery_schedule, closed: false) }

    before do
      switch_to_subdomain market.subdomain
      sign_in_as(user)
    end

    scenario "if the Buyer begins shopping, and the Market Manager closes the market, the Buyer will not be able to check out.", js:true do
      item = Dom::Cart::Item.find_by_name(products[0].name)
      item.set_quantity(12)
      expect(page).to have_content("Added to cart!")
      expect(page).to_not have_content("Added to cart!")
      expect(page).to have_text("Cart 1")

      market_copy = Market.find(market.id)
      market_copy.closed = true
      market_copy.save!

      Dom::CartLink.first.node.click
      expect(page).to have_content("The Market Is Currently Closed")
    end
  end
end
