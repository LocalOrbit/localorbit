require "spec_helper"

feature "Viewing products" do
  let!(:org1) { create(:organization, :seller) }
  let!(:org2) { create(:organization, :seller) }
  let!(:org1_product) { create(:product, organization: org1) }
  let!(:product1_price) { create(:price, product: org1_product) }
  let!(:product1_lot) { create(:lot, product: org1_product) }
  let!(:org2_product) { create(:product, organization: org2) }
  let!(:product2_price) { create(:price, product: org2_product) }
  let!(:product2_lot) { create(:lot, product: org2_product) }
  let(:available_products) { [org1_product, org2_product] }

  let!(:other_org) { create(:organization, :seller) }
  let!(:other_products) { create_list(:product, 3, organization: other_org) }

  let!(:org2_product_deleted) { create(:product, organization: org2, deleted_at: 1.day.ago) }

  let!(:buyer_org) { create(:organization, :multiple_locations, :buyer) }
  let!(:user) { create(:user, organizations: [buyer_org]) }

  let!(:market) { create(:market, :with_addresses, organizations: [org1, org2, buyer_org]) }

  before do
    other_products.each do |prod|
      create(:price, product: prod)
      create(:lot, product: prod)
    end

    Timecop.travel(DateTime.parse("October 7 2014"))
    switch_to_subdomain market.subdomain
    sign_in_as(user)
  end

  after do
    Timecop.return
  end

  scenario "list of products" do
    #TODO: Filter products based on delivery
    #      Since adding the delivery selection, 
    #      this spec is broken. We're not yet filtering
    #      based on the current delivery
    #click_link "Shop"

    #products = Dom::Product.all

    #expect(products).to have(2).products
    #expect(products.map(&:name)).to match_array(available_products.map(&:name))

    #product = available_products.first
    #dom_product = Dom::Product.find_by_name(product.name)

    #expect(dom_product.organization_name).to have_text(product.organization_name)
    #expected_price = "$%.2f" % product.prices.first.sale_price
    #expect(dom_product.pricing).to have_text(expected_price)
    #expect(dom_product.quantity).to have_text(expected_price)
  end

  scenario "shopping without an existing shopping cart" do
    address = market.addresses.first
    address.name = "Market Place"
    address.address = "123 Street Ave."
    address.city = "Town"
    address.state = "MI"
    address.zip = "32339"
    address.save!

    ds = create(:delivery_schedule, :buyer_pickup,
      day: 2,
      order_cutoff: 24,
      seller_fulfillment_location_id: 0,
      seller_delivery_start: "7:00 AM",
      seller_delivery_end:  "11:00 AM",
      buyer_pickup_start: "12:00 PM",
      buyer_pickup_end: "2:00 PM",
      market: market
    )

    create(:delivery, delivery_schedule: ds)

    click_link "Shop"

    expect(page).to have_content("Please choose a pick up or delivery date.")

    delivery_list = Dom::Buying::DeliveryChoice.first
    expect(delivery_list).not_to be_nil

    expect(delivery_list.type).to eql("Pick Up:")
    expect(delivery_list.date).to eql("October 14, 2014")
    expect(delivery_list.time_range).to eql("Between 12:00PM and 2:00PM")
    expect(delivery_list.location.text).to eql("123 Street Ave. Town MI, 32339")

    click_button "Start Shopping"
    expect(page).to have_content("Please select a delivery")
  end

  scenario "shopping after already having a cart"
end
