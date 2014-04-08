require "spec_helper"

describe "Checking Out" do
  let!(:user) { create(:user) }
  let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms", users:[create(:user), create(:user)]) }
  let!(:ada_farms){ create(:organization, :seller, :single_location, name: "Ada Farms", users: [create(:user)]) }

  let(:market_manager) { create(:user) }
  let(:market) { create(:market, :with_addresses, organizations: [buyer, fulton_farms, ada_farms], managers: [market_manager]) }
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

  it "displays copy about the order" do
    checkout
    expect(page).to have_content("You will receive a confirmation email with details of your order and a link to track its progress")
    expect(page).to have_content("If you have any questions, please let us know")
  end

  it "links to the order to review", js: true do
    checkout

    click_link "Review Order"
    expect(page).to have_content("Order info")
    expect(page).to have_content("Bananas")
    expect(page).to have_content("Potatoes")
    expect(page).to have_content("Kale")
  end

  it "sends the buyer an email about the order" do
    checkout
    open_email(user.email)

    expect(current_email).to have_subject("Thank you for your order")
    expect(current_email).to have_body_text("Thank you for your order through #{market.name}")

    visit_in_email "Review Order"
    expect(page).to have_content("Order info")
    expect(page).to have_content("Items for delivery...")
  end

  it "sends the seller email about the order" do
    checkout

    fulton_farms.users.each do |user|
      open_email(user.email)

      expect(current_email).to have_subject("You have a new order!")
      expect(current_email.body).to have_content("You have a new order!")
      # It does not include content from other sellers
      expect(current_email).to have_body_text("Kale")
      expect(current_email).to have_body_text("Bananas")
      expect(current_email).to_not have_body_text("Potatoes")

      expect(current_email.body).to have_content("An order was just placed by #{market.name}")
    end

    ada_farms.users.each do |user|
      sign_out
      sign_in_as(user)
      open_email(user.email)

      expect(current_email).to have_subject("You have a new order!")
      expect(current_email.body).to have_content("You have a new order!")
      # It does not include content from other sellers
      expect(current_email).not_to have_body_text("Kale")
      expect(current_email).not_to have_body_text("Bananas")
      expect(current_email).to have_body_text("Potatoes")

      expect(current_email.body).to have_content("An order was just placed by #{market.name}")
    end
  end

  it "sends the market manager an email about the order" do
    checkout

    sign_out
    sign_in_as(market_manager)
    open_email(market.managers[0].email)

    expect(current_email.body).to have_content("You've received a new order.")
    expect(current_email.body).to have_content("Order Placed By: #{buyer.name}")

    expect(current_email).to have_body_text("Kale")
    expect(current_email).to have_body_text("Bananas")
    expect(current_email).to have_body_text("Potatoes")

    visit_in_email "Check Order Status"
    expect(page).to have_content("Order info")
    expect(page).to have_content("Items for delivery...")
  end

  it "displays the ordered products" do
    checkout
    expect(page).to have_content("Thank you for your order")

    bananas_row = Dom::Order::ItemRow.find_by_name("Bananas")
    expect(bananas_row.node).to have_content("10 boxes")
    expect(bananas_row.node).to have_content("$0.50")
    expect(bananas_row.node).to have_content("$5.00")

    kale_row = Dom::Order::ItemRow.find_by_name("Kale")
    expect(kale_row.node).to have_content("20 boxes")
    expect(kale_row.node).to have_content("$1.00")
    expect(kale_row.node).to have_content("$20.00")

    potatoes_row = Dom::Order::ItemRow.find_by_name("Potatoes")
    expect(potatoes_row.node).to have_content("5 boxes")
    expect(potatoes_row.node).to have_content("$3.00")
    expect(potatoes_row.node).to have_content("$15.00")
  end

  context "for delivery" do
    it "displays the address" do
      checkout
      expect(page).to have_content("Thank you for your order")
      expect(page).to have_content("Your order will be delivered to:")
      expect(page).to have_content("500 S. State Street")
      expect(page).to have_content("Ann Arbor, MI 48109")
    end

    it "displays the delivery times" do
      checkout
      expect(page).to have_content("Thank you for your order")
      expect(page).to have_content("Items for delivery on:")
      expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
    end
  end

  context "for pickup" do
    let(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup,  market: market, day: 5) }

    it "displays the address" do
      checkout
      expect(page).to have_content("Thank you for your order")

      expect(page).to have_content("Your order can be picked up at")
      expect(page).to have_content("44 E. 8th St")
      expect(page).to have_content("Holland, MI 49423")
    end

    it "displays the delivery times" do
      checkout
      expect(page).to have_content("Thank you for your order")

      expect(page).to have_content("Items for pickup on:")
      expect(page).to have_content("May 9, 2014 between 10:00AM and 12:00PM")
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
