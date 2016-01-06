require "spec_helper"

describe Api::V1::DashboardsController do
  describe "/index" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:buyer1) { create(:organization, :single_location, :buyer, users: [user1]) }
    let!(:buyer2) { create(:organization, :single_location, :buyer, users: [user2]) }
    let!(:market) { create(:market, :with_addresses, organizations: [buyer1]) }
    let!(:market_manager) { create(:user, :market_manager, managed_markets: [market]) }

    let!(:delivery_schedule) { create(:delivery_schedule) }
    let!(:delivery)    { delivery_schedule.next_delivery }

    context 'market manager' do

      def login
        Timecop.travel("February 15, 2016")
        switch_to_subdomain market.subdomain
        sign_in market_manager
      end

      before do
        Timecop.travel("February 15, 2016") do
          order_item = create(:order_item, unit_price: 10, quantity: 1)
          order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 10)
          order.save!
        end

        Timecop.travel("February 13, 2016") do
          order_item = create(:order_item, unit_price: 10, quantity: 1)
          order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 10)
          order.save!
        end

        Timecop.travel("February 5, 2016") do
          order_item = create(:order_item, unit_price: 10, quantity: 1)
          order = create(:order, delivery: delivery, items: [order_item], payment_method: "purchase order", market: market, total_cost: 10)
          order.save!
        end

        Timecop.travel("January 5, 2016") do
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
          expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$10'
        end

        it "creates proper JSON - 7D" do
          login
          get :index, ({dateRange: 1, viewAs: 'B'})
          expect(response.status).to eql 200
          expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$20'
        end

        it "creates proper JSON - MTD" do
          login
          get :index, ({dateRange: 2, viewAs: 'B'})
          expect(response.status).to eql 200
          expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$30'
        end

        it "creates proper JSON - YTD" do
          login
          get :index, ({dateRange: 3, viewAs: 'B'})
          expect(response.status).to eql 200
          expect(JSON.parse(response.body)["dashboard"]["totalSalesAmount"]).to eql '$40'
        end
      end
    end
  end
end