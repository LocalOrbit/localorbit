require "spec_helper"

describe "Checking Out" do
  let!(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms") }
  let!(:ada_farms){ create(:organization, :seller, :single_location, name: "Ada Farms") }

  let(:market) { create(:market, :with_addresses, organizations: [buyer, fulton_farms, ada_farms]) }
  let(:delivery_schedule) { create(:delivery_schedule, :percent_fee,  market: market, day: 5) }
  let(:delivery_day) { DateTime.parse("May 9, 2014, 11:00:00") }
  let(:delivery) {
    create(:delivery,
      delivery_schedule: delivery_schedule,
      deliver_on: delivery_day,
      cutoff_time:delivery_day - delivery_schedule.order_cutoff.hours
    )
  }

  # Fulton St. Farms
  let!(:bananas) { create(:product, :sellable, name: "Bananas", organization: fulton_farms) }
  let!(:bananas_lot) { create(:lot, product: bananas, quantity: 100) }
  let!(:bananas_price_buyer_base) {
    create(:price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  }

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: fulton_farms) }
  let!(:kale_lot) { kale.lots.first.update_attribute(:quantity, 100) }
  let!(:kale_price_tier1) {
    create(:price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  }

  let!(:kale_price_tier2) {
    create(:price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
  }

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms) }
  let!(:potatoes_lot) { create(:lot, product: potatoes, quantity: 100) }

  let!(:beans) { create(:product, :sellable, name: "Beans", organization: ada_farms) }

  let!(:cart) { create(:cart, market: market, organization: buyer, location: buyer.locations.first, delivery: delivery) }
  let!(:cart_bananas) { create(:cart_item, cart: cart, product: bananas, quantity: 10) }
  let!(:cart_potatoes) { create(:cart_item, cart: cart, product: potatoes, quantity: 5) }
  let!(:cart_kale) { create(:cart_item, cart: cart, product: kale, quantity: 20) }

  def cart_link
    Dom::CartLink.first
  end

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  def checkout
    click_button "Checkout"
  end

  before do
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)

    # NOTE: the behavior of clicking the cart link will change
    # once the cart preview has been built. See
    # https://www.pivotaltracker.com/story/show/67553382
    cart_link.node.click
    expect(page).to have_content("Your Order")
    expect(page).to have_content("Bananas")
    expect(page).to have_content("Kale")
    expect(page).to have_content("Potatoes")

    fill_in "PO Number", with: "12345"
  end

  it "displays the ordered products" do
    checkout
    expect(page).to have_content("Thank you for your order")
    items = Dom::Order::ItemRow.all
    expect(items.map(&:name)).to include("Bananas", "Potatoes", "Kale")
  end

  context "for delivery" do
    it "displays the address" do
      checkout
      expect(page).to have_content("Thank you for your order")
      expect(page).to have_content("be delivered to")
      expect(page).to have_content("500 S. State Street, Ann Arbor, MI 48109")
    end

    it "displays the delivery times" do
      checkout
      expect(page).to have_content("Thank you for your order")
      expect(page).to have_content("Delivery on")
      expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")

      #TODO: What does Rails show this as?
      expect(page).to have_content("US/Eastern")
    end
  end

  context "for pickup" do
    let(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup,  market: market, day: 5) }

    it "displays the address" do
      checkout
      expect(page).to have_content("Thank you for your order")

      expect(page).to have_content("available for pickup at")
      expect(page).to have_content("44 E. 8th St, Holland, MI 49423")
    end

    it "displays the delivery times" do
      checkout
      expect(page).to have_content("Thank you for your order")

      expect(page).to have_content("Pickup on")
      expect(page).to have_content("May 9, 2014 between 10:00AM and 12:00PM")

      #TODO: What does Rails show this as?
      expect(page).to have_content("US/Eastern")
    end
  end

  it "clears out the cart" do
    checkout
    expect(cart_link.count.text).to eql("0")
  end

  it "inventory has been exhausted since placing product in cart" do
    kale.lots.first.update_attribute(:quantity, 1)
    potatoes.lots.each {|lot| lot.update(quantity: 1) }

    checkout

    expect(cart_link.count.text).to eql("3")
    expect(page).to have_content("Your order could not be completed.")

    expect(page).to have_content("Unfortunately, there are only 2 Potatoes available")
    expect(page).to have_content("Unfortunately, there are only 1 Kale available")
  end
end
