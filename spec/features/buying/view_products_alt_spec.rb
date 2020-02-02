require "spec_helper"

feature "Viewing products" do
  let(:market_org) { create(:organization, :market, :single_location, payment_model: 'consignment') }
  let!(:market) { create(:market, :with_addresses, organization: market_org) }
  let!(:delivery_schedule1) { create(:delivery_schedule, :buyer_pickup,
                                     market: market,
                                     delivery_cycle: 'manual',
                                     order_cutoff: 0) }
  let!(:delivery_schedule2) { create(:delivery_schedule, market: market, day: 3, deleted_at: Time.zone.parse("2013-03-21")) }

  let!(:org1) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:org1_product) { create(:product, :sellable, name: "celery", organization: org1, delivery_schedules: [delivery_schedule1]) }

  let!(:org2) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:org2_product) { create(:product, :sellable, organization: org2, delivery_schedules: [delivery_schedule1]) }
  let!(:org2_product_deleted) { create(:product, :sellable, organization: org2, deleted_at: Time.zone.parse("2014-10-01")) }

  let!(:inactive_org) { create(:organization, :seller, :single_location, active: false, markets: [market]) }
  let!(:inactive_org_product) { create(:product, :sellable, organization: inactive_org, delivery_schedules: [delivery_schedule1]) }

  let!(:other_org) { create(:organization, :seller, :single_location) }
  let!(:other_products) { create_list(:product, 3, :sellable, organization: other_org) }

  let!(:buyer_org) { create(:organization, :buyer, :single_location, markets: [market]) }
  let(:user) { create(:user, :buyer, organizations: [buyer_org]) }
  let(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

  let(:available_products) { [org1_product, org2_product] }

  let(:po_item) { create(:order_item, product: org1_product) }
  let(:purchase_order) { create(:order, :consignment_po, items:[po_item]) }
  let(:sales_order) { create(:order, :consignment_so) }

  def consigbnment_celery_item
    Dom::Cart::POItem.find_by_name("celery")
  end

  def celery_item
    Dom::Cart::ConsignmentItem.find_by_name("celery")
  end

  def cart_link
    Dom::CartLink.first
  end

  before do
    Timecop.travel(Time.zone.parse("October 7 2014"))
    switch_to_subdomain market.subdomain
  end

  after do
    Timecop.return
  end

  it "Purchase Order", :js do
    sign_in_as(market_manager)
    click_link("Purchase Order", match: :first)

    expect(page).to have_content("Select a Supplier")
    select org1.name, from: "Supplier", visible: false
    click_button "Select Supplier"

    # TODO: Fix alternative order page test to check for items in catalog

    expect(page).to have_content("Please choose a delivery date")
    fill_in("buyer_deliver_on", with: "04 Apr 2017")
    click_button "Start Ordering"

    expect(page).to have_content("celery")
    celery_item.set_quantity(1)
    expect(Dom::CartLink.first.count).to have_content("1")
  end

  xit "Sales Order", :js do
    sign_in_as(market_manager)
    click_link("Sales Order", match: :first)

    expect(page).to have_content("Select a Buyer")
    select buyer_org.name, from: "Buyer", visible: false
    click_button "Select Buyer"

    # TODO: Fix alternative order page test to check for items in catalog

    expect(page).to have_content("Please choose a delivery date")
    fill_in("buyer_deliver_on", with: "04 Apr 2017")
    click_button "Start Ordering"

    expect(page).to have_content("celery")
    celery_item.set_quantity(1)
    expect(Dom::CartLink.first.count).to have_content("0")

    celery_item.set_sale_price(4)
    expect(Dom::CartLink.first.count).to have_content("0")

    celery_item.set_net_price(3)
    expect(Dom::CartLink.first.count).to have_content("1")
  end

end