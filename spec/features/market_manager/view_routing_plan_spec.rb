require "spec_helper"

describe "Routing Plan" do
  let!(:market)            { create(:market) }

  let(:thursdays_schedule) { create(:delivery_schedule, market: market, day: 4) }
  let(:thursday_delivery)  { create(:delivery, delivery_schedule: thursdays_schedule, deliver_on: Date.parse("May 8, 2014")) }

  let(:seller)             { create(:organization, :seller, :single_location, markets: [market]) }
  let(:product)            { create(:product, :sellable, organization: seller) }

  let(:buyer)             { create(:organization, :buyer, markets: [market]) }
  let!(:buyer_location)   { create(:location, organization: buyer, address: "66-140 Kamehameha Hwy", city: "Haleiwa", state: "HI", zip: "96712") }
  let(:buyer_delivery)    { {delivery_address: buyer.locations.first.address, delivery_city: buyer.locations.first.city, delivery_state: buyer.locations.first.state, delivery_zip: buyer.locations.first.zip, delivery_phone: buyer.locations.first.phone} }

  let(:order_item)         { create(:order_item, product: product, quantity: 2, unit_price: 3.00) }
  let(:order)              { create(:order, buyer_delivery.merge(items: [order_item], delivery: thursday_delivery, market: market, organization: buyer)) }

  before do
    Timecop.travel("May 5, 2014")
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  after do
    Timecop.return
  end

  context "as a market manager on an accelerate market" do
    let(:user) { create(:user, :market_manager, managed_markets: [market]) }
    let(:role) { create(:role, :accelerate_plan)}

    before do
      user.roles = [role]
      market.addresses = [address]
      date_str = thursday_delivery.buyer_deliver_on.strftime("%Y%m%d")
      visit admin_delivery_tools_pack_list_path(date_str, market_id: market.id)
    end

    context "with valid market address", js: true do
      let(:address) { create(:market_address, market: market, address: "66-434 Kamehameha Hwy", city: "Haleiwa", state: "HI", zip: "96712", phone: "(321) 456-3456") }

      it "the routing plan is visible" do
        skip 'Temporarily removed Geocode to get past Ruby 2.4 and Rails 4.2 upgrade to move to AWS. Revisit.'
        expect(page).to have_content("Routing Plan")
        routing_plan = Dom::Admin::RoutingPlan.first
        expect(routing_plan.path).to have_content(/Trip duration: [\w\. ]+ sec/)
        expect(routing_plan.path).to have_content(/Trip length: [0-9\.]+ miles?/)
      end
    end

    context "with invalid market address", js: true do
      let(:address) { create(:market_address, market: market, address: "Afdakslfjklasfjkldsjfklsdjfkl", city: "Uruieorueiorueior", state: "HI", zip: "90000", phone: "(321) 456-3456") }

      # TODO: How would I stub current_market.addresses.visible.first.geocode to return nil in the view
      # to simulate geocode failing since geocode defaults to Holland, MI in specs (see geocoder.rb)?

      xit "the routing plan is not displayed" do
        expect(page).to_not have_content("Routing Plan")
        routing_plan = Dom::Admin::RoutingPlan.first
        expect(routing_plan).to be_nil
      end
    end
  end
end