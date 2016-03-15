require "spec_helper"

feature "Viewing products" do
  let!(:market) { create(:market, :with_addresses, alternative_order_page: true) }
  let!(:delivery_schedule1) { create(:delivery_schedule, :buyer_pickup,
                                     market: market,
                                     order_cutoff: 24,
                                     day: 5,
                                     buyer_pickup_location_id: 0,
                                     buyer_pickup_start: "12:00 PM",
                                     buyer_pickup_end: "2:00 PM") }
  let!(:delivery_schedule2) { create(:delivery_schedule, market: market, day: 3, deleted_at: Time.zone.parse("2013-03-21")) }

  let!(:org1) { create(:organization, :seller, markets: [market]) }
  let!(:org1_product) { create(:product, :sellable, name: "celery", organization: org1, delivery_schedules: [delivery_schedule1]) }
  let!(:promotion) { create(:promotion, :active, product: org1_product, market: market, body: "Big savings!") }

  let!(:org2) { create(:organization, :seller, markets: [market]) }
  let!(:org2_product) { create(:product, :sellable, organization: org2, delivery_schedules: [delivery_schedule1]) }
  let!(:org2_product_deleted) { create(:product, :sellable, organization: org2, deleted_at: Time.zone.parse("2014-10-01")) }

  let!(:inactive_org) { create(:organization, :seller, active: false, markets: [market]) }
  let!(:inactive_org_product) { create(:product, :sellable, organization: inactive_org, delivery_schedules: [delivery_schedule1]) }

  let!(:other_org) { create(:organization, :seller) }
  let!(:other_products) { create_list(:product, 3, :sellable, organization: other_org) }

  let!(:buyer_org) { create(:organization, :single_location, :buyer, markets: [market]) }
  let(:user) { create(:user, organizations: [buyer_org]) }
  let(:market_manager) { create(:user, managed_markets: [market]) }

  let(:available_products) { [org1_product, org2_product] }

  def celery_item
    Dom::Cart::Item.find_by_name("celery")
  end

  before do
    Timecop.travel(Time.zone.parse("October 7 2014"))
    switch_to_subdomain market.subdomain
  end

  after do
    Timecop.return
  end

  scenario "alternate products page", :js do
    sign_in_as(user)
    expect(page).to have_content("celery")
    expect(page).to have_content(org2_product.name)
    fill_in("app-search", with: "celery")
    expect(page).to have_content("celery")
    expect(page).not_to have_content(org2_product.name)
  end
end