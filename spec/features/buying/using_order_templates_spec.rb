require "spec_helper"

describe "Using order templates", :js do
  let!(:buyer) { create(:organization, :single_location, :buyer) }
  let!(:credit_card)  { create(:bank_account, :credit_card, bankable: buyer, stripe_id: 'fake stripe id') }
  let!(:bank_account) { create(:bank_account, :checking, :verified, bankable: buyer, stripe_id: 'another fake stripe id') }

  let!(:fulton_farms) { create(:organization, :seller, :single_location, name: "Fulton St. Farms", users: [create(:user), create(:user)]) }
  let!(:ada_farms) { create(:organization, :seller, :single_location, name: "Ada Farms", users: [create(:user)]) }

  let(:market_manager) { create(:user, :market_manager) }
  let(:plan) {create(:plan, :localeyes)}
  let(:market_org) { create(:organization, :market, plan: plan)}
  let(:market) { create(:market, :with_addresses, organization: market_org, organizations: [buyer, fulton_farms, ada_farms], managers: [market_manager], alternative_order_page: true) }
  let!(:delivery_schedule) { create(:delivery_schedule, :percent_fee,  market: market, day: 5) }
  let!(:delivery_day) { DateTime.parse("May 9, 2014, 11:00:00") }
  let!(:delivery) do
    create(:delivery,
           delivery_schedule: delivery_schedule,
           deliver_on: delivery_day,
           cutoff_time: delivery_day - delivery_schedule.order_cutoff.hours
    )
  end
  let!(:user) { create(:user, :buyer, organizations:[buyer]) }
  let!(:other_buying_user) {  create(:user, :buyer, organizations:[buyer]) }

  # Fulton St. Farms
  let!(:bananas) { create(:product, name: "Bananas", organization: fulton_farms) }
  let!(:bananas_lot) { create(:lot, product: bananas, quantity: 100) }
  let!(:bananas_price_buyer_base) do
    create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer, sale_price: 0.50)
  end

  let!(:kale) { create(:product, :sellable, name: "Kale", organization: fulton_farms) }
  let!(:kale_lot) { kale.lots.first.update_attribute(:quantity, 100) }
  let!(:kale_price_tier1) do
    create(:price, :past_price, market: market, product: kale, min_quantity: 4, sale_price: 2.50)
  end

  let!(:promotion) { create(:promotion, :active, product: bananas, market: market, body: "Big savings!") }

  let!(:kale_price_tier2) do
    create(:price, :past_price, market: market, product: kale, min_quantity: 6, sale_price: 1.00)
  end

  # Ada Farms
  let!(:potatoes) { create(:product, :sellable, name: "Potatoes", organization: ada_farms) }
  let!(:potatoes_lot) { create(:lot, product: potatoes, quantity: 100) }

  let!(:beans) { create(:product, :sellable, name: "Beans", organization: ada_farms) }

  def create_cart
    cart = create(:cart, market: market, organization: buyer, user: user, location: buyer.locations.first, delivery: delivery)
    create(:cart_item, cart: cart, product: bananas, quantity: 10)
    create(:cart_item, cart: cart, product: potatoes, quantity: 5)
    create(:cart_item, cart: cart, product: kale, quantity: 20)
  end

  def create_template
    order_template = create(:order_template, market: market)
    create(:order_template_item, order_template: order_template, product: bananas, quantity: 10)
    create(:order_template_item, order_template: order_template, product: potatoes, quantity: 5)
    create(:order_template_item, order_template: order_template, product: kale, quantity: 20)
  end

  def cart_link
    Dom::CartLink.find!
  end

  before do
    VCR.turn_off!
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
    VCR.turn_on!
  end

  def checkout
    click_button "Place Order"
  end

  def login
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  it "creates a template" do
    create_cart
    login
    cart_link.node.click
    expect(page).to have_content("Your Order")
    expect(page).to have_content("Bananas")
    expect(page).to have_content("Kale")
    expect(page).to have_content("Potatoes")

    find(".app-create-template-link").click
    find(".app-template-name").set("new template")
    find(".app-save-template").click
    expect(page).to have_content "Order Templates"
    expect(find_all(".app-template").count).to eq 1
    expect(find(".app-template-name").text).to eq "new template"
  end

  it "can be applied to an order" do
    create_template
    login
    visit products_path

    expect(page).to_not have_content "Loading products"
    find(".app-apply-template").click
    expect(page).to have_content "Order Templates"
    click_button("Apply")

    expect(page).to have_content("Your Order")
    expect(page).to have_content("Bananas")
    expect(page).to have_content("Kale")
    expect(page).to have_content("Potatoes")
  end
end
