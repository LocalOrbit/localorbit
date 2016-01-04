require "spec_helper"

describe Api::V1::DashboardsController do
  describe "/index" do
    let!(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:market) { create(:market, :with_addresses, organizations: [buyer]) }
    let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

    let!(:delivery_schedule) { create(:delivery_schedule) }
    let!(:delivery)    { delivery_schedule.next_delivery }

    def login
      switch_to_subdomain market.subdomain
      sign_in market_manager
    end

    before do
      Timecop.travel(Time.current) do
        order_item = create(:order_item, unit_price: 10, quantity: 2)
        order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 20)
        order.save!
      end

      Timecop.travel(Time.current - 1.day) do
        order_item = create(:order_item, unit_price: 10, quantity: 1)
        order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 10)
        order.save!
      end
    end

    describe "viewing dashboard" do
      it "creates proper JSON - 1D" do
        login
        get :index, ({dateRange: 0, viewAs: 'B'})
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$20'
      end

      it "creates proper JSON - 7D" do
        login
        get :index, ({dateRange: 1, viewAs: 'B'})
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$30'
      end
    end
  end
end