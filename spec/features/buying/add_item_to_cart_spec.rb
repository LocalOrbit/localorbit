require "spec_helper"

describe "Add item to cart", js: true do
  let(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:seller) {create(:organization, :seller) }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, seller]) }
  let!(:pickup) { create(:delivery_schedule, :buyer_pickup, market: market) }
  let!(:delivery) { create(:delivery_schedule, market: market) }

  # Products
  let(:bananas) { create(:product, name: "Bananas", organization: seller) }
  let!(:bananas_lot) { create(:lot, product: bananas) }
  let!(:bananas_price_buyer_base) {
    create(:price, market: market, product: bananas, min_quantity: 1, organization: buyer)
  }

  let(:bananas_price_everyone_base) {
    create(:price, market: market, product: bananas, min_quantity: 1)
  }

  let(:kale) { create(:product, name: "kale", organization: seller) }
  let!(:kale_lot) { create(:lot, product: kale) }
  let!(:kale_price_buyer_base) {
    create(:price, market: market, product: kale, min_quantity: 1)
  }

  before do
    Timecop.travel("May 8, 2014")
  end

  after do
    Timecop.return
  end

  context "with an empty cart" do
    it "updates the item count" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      find(:link, "Shop").trigger("click")
      choose_delivery

      expect(page).to have_content("Filter the Shop")

      expect(Dom::CartLink.first.node).to have_content("0")

      bananas = Dom::Buying::ProductRow.find_by_name("Bananas")
      kale = Dom::Buying::ProductRow.find_by_name("kale")

      bananas.set_quantity(12)
      kale.quantity_field.click
      expect(Dom::CartLink.first.node).to have_content("1")

      kale.set_quantity(9)
      bananas.quantity_field.click
      expect(Dom::CartLink.first.node).to have_content("2")
      sleep 1
      # Refreshing the page should retain the state of the cart
      visit "/products"

      bananas = Dom::Buying::ProductRow.find_by_name("Bananas")
      kale = Dom::Buying::ProductRow.find_by_name("kale")

      expect(Dom::CartLink.first.node).to have_content("2")
      expect(bananas.quantity_field.value).to eql("12")
      expect(kale.quantity_field.value).to eql("9")
    end
  end

  context "with a partially filled cart" do
    let!(:cart) { create(:cart, market: market, organization: buyer, delivery: pickup.next_delivery) }
    let!(:item) { create(:cart_item, cart: cart, product: bananas, quantity: 19) }

    it "initializes the client cart code" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      find(:link, "Shop").trigger("click")
      choose_delivery("Pick Up: May 13, 2014 Between 10:00AM and 12:00PM")

      expect(page).to have_content("Filter the Shop")

      bananas = Dom::Buying::ProductRow.find_by_name("Bananas")
      kale = Dom::Buying::ProductRow.find_by_name("kale")

      expect(bananas.quantity_field.value).to eql("19")
      expect(kale.quantity_field.value).to be_blank

      expect(Dom::CartLink.first.node).to have_content("1")

      kale.quantity_field.set("10")
      bananas.quantity_field.click

      expect(Dom::CartLink.first.node).to have_content("2")
    end

    it "does not update the counter when an item quantity is updated" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      find(:link, "Shop").trigger("click")
      choose_delivery("Pick Up: May 13, 2014 Between 10:00AM and 12:00PM")
      expect(Dom::CartLink.first.node).to have_content("1")

      bananas = Dom::Buying::ProductRow.find_by_name("Bananas")
      kale = Dom::Buying::ProductRow.find_by_name("kale")

      bananas.set_quantity(8)
      kale.quantity_field.click
      expect(Dom::CartLink.first.node).to have_content("1")

      bananas.set_quantity(9)
      kale.quantity_field.click
      expect(Dom::CartLink.first.node).to have_content("1")

      visit "/products"
      bananas = Dom::Buying::ProductRow.find_by_name("Bananas")
      expect(bananas.quantity_field.value).to eql("9")
      expect(Dom::CartLink.first).to have_content("1")
    end
  end
end
