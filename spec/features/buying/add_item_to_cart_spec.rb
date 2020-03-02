require "spec_helper"

describe "Add item to cart", :js do
  let(:user) { create(:user, :buyer) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
  let!(:seller) { create(:organization, :seller, :single_location) }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, seller]) }
  let!(:delivery) { create(:delivery_schedule, market: market) }

  # Products
  let(:bananas) { create(:product, name: "Bananas", organization: seller, delivery_schedules: [delivery]) }
  let!(:bananas_lot) { create(:lot, product: bananas) }
  let!(:bananas_price_buyer_base) do
    create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer)
  end

  let(:bananas_price_everyone_base) do
    create(:price, :past_price, market: market, product: bananas, min_quantity: 1)
  end

  let(:kale) { create(:product, name: "Kale", organization: seller, delivery_schedules: [delivery]) }
  let!(:kale_lot) { create(:lot, product: kale) }
  let!(:kale_price_buyer_base) do
    create(:price, :past_price, market: market, product: kale, min_quantity: 1)
  end

  def bananas_row
    Dom::ProductListing.find_by_name("Bananas")
  end

  def kale_row
    Dom::ProductListing.find_by_name("Kale")
  end

  def cart_link
    Dom::CartLink.first
  end

  before do
    Timecop.travel("May 8, 2014")
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
    go_to_order_page
  end

  after do
    Timecop.return
  end

  it "enables/disables the ability depending on how many items are in your cart" do
    expect(cart_link.node).to have_content("0")

    cart_link.node.click
    expect(page).to have_content("Your cart is empty")
    page.find(".overlay").click

    bananas_row.set_quantity(12)
    expect(page).to have_content("Added to cart!")

    cart_link.node.click
    expect(page).to have_content("Your Order")
    expect(page).to have_content("Bananas")
  end

  context "with an empty cart" do
    before do
      expect(page).to have_content("Filter")
      expect(page).to have_content("Bananas")
      expect(page).to have_content("Kale")

      expect(bananas_row.node).to have_content("$0.00")
      expect(kale_row.node).to have_content("$0.00")

      expect(Dom::CartLink.first.count).to have_content("0")
      expect(page).not_to have_content("Checkout")
    end

    it "updates the item count" do
      bananas_row.set_quantity(12)

      expect(page).to have_content("Added to cart!")
      expect(Dom::CartLink.first.count).to have_content("1")

      expect(page).to have_content("Checkout")

      kale_row.set_quantity(9)
      expect(page).to have_content("Added to cart!")
      expect(Dom::CartLink.first.count).to have_content("2")

      # Refreshing the page should retain the state of the cart
      go_to_order_page

      expect(Dom::CartLink.first.node).to have_content("2")

      expect(bananas_row.quantity_field.value).to eql("12")
      expect(bananas_row.node).to have_content("$36.00")

      expect(kale_row.quantity_field.value).to eql("9")
      expect(kale_row.node).to have_content("$27.00")
    end

    it "does not error when 0 is entered for an new item" do
      bananas_row.set_quantity(0)

      expect(Dom::CartLink.first.count).to have_content("0")
      expect(page).to_not have_content("Checkout")
    end
  end

  context "with a partially filled cart" do
    let!(:cart)      { create(:cart, market: market, organization: buyer, user: user, delivery: delivery.next_delivery) }
    let!(:cart_item) { create(:cart_item, product: bananas, cart: cart, quantity: 1) }

    it "does not update the counter when an item quantity is updated" do
      skip 'Valid spec, need to fix regression'
      expect(Dom::CartLink.first).to have_content("1")
      expect(bananas_row.node).to have_content("$3.00")

      bananas_row.set_quantity(8)
      expect(page).to have_content("Item updated!")

      expect(Dom::CartLink.first.count).to have_content("1")
      expect(bananas_row.node).to have_content("$24.00")

      bananas_row.set_quantity(9)
      expect(page).to have_content("Item updated!")

      expect(Dom::CartLink.first.count).to have_content("1")
      expect(bananas_row.node).to have_content("$27.00")

      go_to_order_page
      expect(bananas_row.quantity_field.value).to eql("9")
      expect(Dom::CartLink.first.count).to have_content("1")
      expect(bananas_row.node).to have_content("$27.00")
    end
  end

  context "purchasing less product than required minimum" do
    let(:tomatoes) { create(:product, name: "Tomatoes", organization: seller, delivery_schedules: [delivery]) }
    let!(:tomatoes_lot) { create(:lot, product: tomatoes) }
    let!(:tomatoes_price_buyer_base) do
      create(:price, :past_price, market: market, product: tomatoes, min_quantity: 5)
    end

    def tomatoes_row
      Dom::ProductListing.find_by_name("Tomatoes")
    end

    it "shows an error message" do
      skip 'Valid spec, need to fix regression'
      expect(page).to have_content("Filter")
      expect(page).to have_content("Bananas")
      expect(page).to have_content("Kale")

      tomatoes_row.set_quantity(3)
      expect(page).to have_content("Added to cart!")
      expect(page).to_not have_content("Added to cart!")
      expect(page).to have_content("You must order at least 5")
    end
  end
end
