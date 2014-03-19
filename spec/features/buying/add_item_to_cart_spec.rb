require "spec_helper"

describe "Add item to cart", js: true do
  let(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:seller) {create(:organization, :seller) }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, seller]) }
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

  def bananas_row
    Dom::Cart::Item.find_by_name("Bananas")
  end

  def kale_row
    Dom::Cart::Item.find_by_name("kale")
  end


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

      expect(page).to have_content("Filter the Shop")

      expect(Dom::CartLink.first).to have_count(0)

      bananas_row.set_quantity(12)
      kale_row.quantity_field.click
      expect(Dom::CartLink.first).to have_count(1)

      kale_row.set_quantity(9)
      bananas_row.quantity_field.click
      expect(Dom::CartLink.first).to have_count(2)
      sleep 1

      # Refreshing the page should retain the state of the cart
      visit "/products"

      expect(Dom::CartLink.first.node).to have_content("2")
      expect(bananas_row.quantity_field.value).to eql("12")
      expect(kale_row.quantity_field.value).to eql("9")
    end
  end

  context "with a partially filled cart" do
    let!(:cart) { create(:cart, market: market, organization: buyer, delivery: pickup.next_delivery) }
    let!(:item) { create(:cart_item, cart: cart, product: bananas, quantity: 19) }
    let!(:pickup) { create(:delivery_schedule, :buyer_pickup, market: market) }

    it "initializes the client cart code" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      choose_delivery("Pick Up: May 13, 2014 Between 10:00AM and 12:00PM")

      expect(page).to have_content("Filter the Shop")

      expect(bananas_row.quantity_field.value).to eql("19")
      expect(kale_row.quantity_field.value).to be_blank

      expect(Dom::CartLink.first).to have_count(1)

      kale_row.quantity_field.set("10")
      bananas_row.quantity_field.click

      expect(Dom::CartLink.first).to have_count(2)
    end

    it "does not update the counter when an item quantity is updated" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      choose_delivery("Pick Up: May 13, 2014 Between 10:00AM and 12:00PM")
      expect(Dom::CartLink.first).to have_count(1)

      bananas_row.set_quantity(8)
      kale_row.quantity_field.click
      expect(Dom::CartLink.first).to have_count(1)

      bananas_row.set_quantity(9)
      kale_row.quantity_field.click

      expect(Dom::CartLink.first).to have_count(1)

      visit "/products"
      expect(bananas_row.quantity_field.value).to eql("9")
      expect(Dom::CartLink.first).to have_count(1)
    end
  end
end
