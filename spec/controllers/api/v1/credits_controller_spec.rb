require "spec_helper"

describe Api::V1::CreditsController do
  describe "/index" do
    let(:user) { create(:user) }
    let(:admin) {create(:user, :admin)}
    let(:market_manager) {create(:user, managed_markets: [market])}
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let(:market) { create(:market, :with_addresses, organizations: [buyer]) }
    let(:order) {create(:order, :with_items, market: market)}

    describe "authorized uses" do
      before do
        switch_to_subdomain market.subdomain
        sign_in [admin, market_manager].sample
      end

      it "allows for the creation of new credits" do
        expect(order.credit).to eql nil
        credit_params = attributes_for(:credit, order: order)
        post :create, {credit: credit_params, order_id: order.id}
        order.reload
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)["credit"]["id"]).to eql order.credit.id
        expect(order.credit).to have_attributes(credit_params)
      end

      it "updates existing credits" do
        credit = create(:credit, order: order)
        expect(order.credit.amount).to eql 1.5
        credit_params = {
          id: credit.id,
          amount: 20,
          amount_type: Credit::PERCENTAGE,
          payer_type: Credit::ORGANIZATION,
          paying_org_id: order.sellers.sample.id
        }
        post :create, {credit: credit_params, order_id: credit.order_id}
        credit.reload
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)["credit"]["id"]).to eql credit.id
        expect(credit).to have_attributes(credit_params)
      end

      it "has error handling" do
        credit_params = attributes_for(:credit, order: order, amount: order.gross_total + 100)
        post :create, {credit: credit_params, order_id: order.id}
        expect(response.status).to eql 400
        expect(JSON.parse(response.body)["errors"]).to match /^Amount can't exceed/
      end
    end

    describe "unauthorized users" do
      def expect_rejection(params)
        post :create, params
        expect(response.status).to eql 404
      end

      it "rejects attempts from regular users" do
        sign_in user
        credit_params = attributes_for(:credit, order: order)
        expect_rejection({credit: credit_params, order_id: order.id})
      end

      it "only allows MMs to assign credits to markets that they control" do
        random_market = create(:market)
        random_order = create(:order, :with_items, market: random_market)
        credit_params = attributes_for(:credit, order: random_order)
        sign_in market_manager
        expect_rejection({credit: credit_params, order_id: random_order.id})
      end
    end
  end
end