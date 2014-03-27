require "spec_helper"

describe "Add item to cart", js: true do
  let(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:seller) {create(:organization, :seller, :single_location) }

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

  let(:kale) { create(:product, name: "Kale", organization: seller) }
  let!(:kale_lot) { create(:lot, product: kale) }
  let!(:kale_price_buyer_base) {
    create(:price, market: market, product: kale, min_quantity: 1)
  }

  def bananas_row
    Dom::Cart::Item.find_by_name("Bananas")
  end

  def kale_row
    Dom::Cart::Item.find_by_name("Kale")
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
      expect(page).to have_content("Bananas")
      expect(page).to have_content("Kale")

      expect(bananas_row.price).to have_content("$0.00")
      expect(kale_row.price).to have_content("$0.00")

      expect(Dom::CartLink.first.count).to have_content("0")

      bananas_row.set_quantity(12)
      kale_row.quantity_field.click
      expect(bananas_row.node).to have_css(".updated.finished")
      expect(Dom::CartLink.first.count).to have_content("1")

      kale_row.set_quantity(9)
      bananas_row.quantity_field.click
      expect(kale_row.node).to have_css(".updated.finished")
      expect(Dom::CartLink.first.count).to have_content("2")


      # Refreshing the page should retain the state of the cart
      visit "/products"

      expect(Dom::CartLink.first.node).to have_content("2")

      expect(bananas_row.quantity_field.value).to eql("12")
      expect(bananas_row.price).to have_content("$36.00")

      expect(kale_row.quantity_field.value).to eql("9")
      expect(kale_row.price).to have_content("$27.00")
    end
  end

  context "with a partially filled cart" do
    let!(:cart) { create(:cart, market: market, organization: buyer, delivery: delivery.next_delivery) }
    let!(:cart_item) { create(:cart_item, product: bananas, cart: cart, quantity: 1) }

    before do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
    end

    it "does not update the counter when an item quantity is updated" do
      expect(Dom::CartLink.first).to have_content("1")
      expect(bananas_row.price).to have_content("$3.00")

      bananas_row.set_quantity(8)
      kale_row.quantity_field.click
      expect(bananas_row.node).to have_css(".updated.finished")

      expect(Dom::CartLink.first.count).to have_content("1")
      expect(bananas_row.price).to have_content("$24.00")

      bananas_row.set_quantity(9)
      kale_row.quantity_field.click
      expect(bananas_row.node).to have_css(".updated.finished")

      expect(Dom::CartLink.first.count).to have_content("1")
      expect(bananas_row.price).to have_content("$27.00")

      visit "/products"
      expect(bananas_row.quantity_field.value).to eql("9")
      expect(Dom::CartLink.first.count).to have_content("1")
      expect(bananas_row.price).to have_content("$27.00")
    end
  end
end
