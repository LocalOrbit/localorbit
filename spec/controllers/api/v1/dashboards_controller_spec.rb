require "spec_helper"

describe Api::V1::DashboardsController do
  describe "/index" do
    let!(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:market) { create(:market, :with_addresses, organizations: [buyer]) }
    let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

    let!(:delivery_schedule) { create(:delivery_schedule) }
    let!(:delivery)    { delivery_schedule.next_delivery }

    let!(:order_item1) { create(:order_item, unit_price: 10.00, quantity: 2) }
    let!(:order1) { create(:order, delivery: delivery, items: [order_item1], total_cost: 20.00, order_number: "LO-14-TEST-1", market: market) }

    Timecop.travel(DateTime.now + 1.day)

    let!(:order_item2) { create(:order_item, unit_price: 10.00, quantity: 1) }
    let!(:order2) { create(:order, delivery: delivery, items: [order_item2], total_cost: 10.00, order_number: "LO-14-TEST-2", market: market) }

    Timecop.return

    def login
      switch_to_subdomain market.subdomain
      sign_in market_manager
    end

    describe "viewing dashboard" do
      it "creates proper JSON - 1D" do
        login
        get :index, "{'dateRange': '0', 'viewAs': 'B'}"
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$20'
      end

      it "creates proper JSON - 7D" do
        login
        get :index, "{'dateRange': '1', 'viewAs': 'B'}"
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$30'
      end
    end
  end
end