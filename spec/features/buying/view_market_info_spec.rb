require "spec_helper"

feature "Viewing Market Info" do
  let!(:buyer) { create(:organization, :buyer) }
  let!(:seller1) { create(:organization, :seller) }
  let!(:seller2) { create(:organization, :seller) }
  let!(:user) { create(:user, organizations: [buyer]) }
  let!(:market) { create(:market, :with_addresses, organizations: [buyer, seller1, seller2]) }

  before do
    switch_to_subdomain market.subdomain
    sign_in_as(user)
  end

  scenario "current market information is visible" do
    click_link "Market Info", match: :first

    expect(page).to have_content(market.name)
    expect(page).to have_content(market.contact_name)
    expect(page).to have_content(market.contact_email)
    expect(page).to have_content(market.policies)
    expect(page).to have_content(market.profile)
    expect(page).to have_css("#admin-nav", visible: false)

    sellers = Dom::MarketSellers.all
    expect(sellers.map(&:name)).to match_array([seller1.name, seller2.name])
  end

  context "market address" do
    let!(:address) { create(:market_address, market: market) }

    scenario "is displayed on the page" do
      click_link "Market Info", match: :first

      expect(page).to have_content(address.address)
      expect(page).to have_content(address.city)
      expect(page).to have_content(address.state)
      expect(page).to have_content(address.zip)
    end
  end

  context "delivery_schedules" do
    let!(:tuesday_deliveries) { create(:delivery_schedule, market: market, seller_fulfillment_location_id: 0, seller_delivery_start: "8:00AM", seller_delivery_end: "11:00AM") }
    let!(:thursday_deliveries) { create(:delivery_schedule, market: market, day: 4, seller_fulfillment_location_id: market.addresses.first.id, buyer_pickup_location_id: 0, buyer_pickup_start: "12:00PM", buyer_pickup_end: "5:00PM") }
    let!(:friday_deliveries) { create(:delivery_schedule, market: market, day: 5, seller_fulfillment_location_id: market.addresses.first.id, buyer_pickup_location_id: market.addresses.first.id, buyer_pickup_start: "12:00PM", buyer_pickup_end: "5:00PM") }

    scenario "are displayed on the page correctly" do
      click_link "Market Info", match: :first

      deliveries = Dom::Info::DeliverySchedule.all

      expect(deliveries.count).to eql(3)
      expect(deliveries[0].display_date).to have_content(tuesday_deliveries.weekday)
      expect(deliveries[0].time_range).to have_content("8:00AM to 11:00AM")
      expect(deliveries[0].location).to have_content("direct to customer")
      expect(deliveries[1].display_date).to have_content(thursday_deliveries.weekday)
      expect(deliveries[1].time_range).to have_content("12:00PM to 5:00PM")
      expect(deliveries[1].location).to have_content("direct to customer")
      expect(deliveries[2].display_date).to have_content(friday_deliveries.weekday)
      expect(deliveries[2].time_range).to have_content("12:00PM to 5:00PM")
      expect(deliveries[2].location).to have_content("pickup at")
    end
  end
end
