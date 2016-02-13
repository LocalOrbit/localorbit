require "spec_helper"

describe Sessions::DeliveriesController do
  let!(:current_market) { create(:market, timezone: "US/Eastern") }
  let!(:schedule) do
    create(:delivery_schedule, market: current_market,
            order_cutoff: 6, seller_delivery_start: "6:00 am", seller_delivery_end: "10:00 am", day: 4)
  end

  let!(:user) { create(:user) }
  let!(:org)  { create(:organization, :multiple_locations, markets: [current_market], users: [user]) }

  before do
    switch_to_subdomain current_market.subdomain
    sign_in(user)
  end

  describe "/create" do
    let!(:delivery) { schedule.next_delivery }

    context "empty submission" do
      context "with multiple delivery schedules" do
        let!(:schedule2) { create(:delivery_schedule, market: current_market, day: 2, seller_delivery_start: "6:00 am", seller_delivery_end: "10:00 am") }

        it "assigns a flash message" do
          post :create, {delivery_id: ""}, current_organization_id: org.id

          expect(flash[:alert]).to eql("Please select a delivery")
        end
      end

      context "with one delivery schedule" do
        it "completes and redirects to the shop" do
          post :create, {delivery_id: ""}, current_organization_id: org.id

          expect(session[:current_delivery_id]).to eql(delivery.id)
          expect(response).to redirect_to([:products])
        end
      end
    end

    context "current_organization has one location" do
      let!(:org) { create(:organization, :single_location, markets: [current_market], users: [user]) }

      before do
        expect(Cart.count).to eql(0)
        post :create,
             {
               delivery_id: delivery.id,
               location_id: {delivery.id.to_s => org.locations.first.id}
             }, current_organization_id: org.id
      end

      it "assigns the delivery" do
        expect(session[:current_delivery_id]).to eql(delivery.id)
      end

      it "redirects to the products listing" do
        expect(response).to redirect_to([:products])
      end

      it "assigns the default organization id" do
        expect(session[:current_location]).to eql(org.locations.first.id)
      end
    end

    context "an organization_location is also passed as a parameter" do

      context "and the location is valid" do
        before do
          post :create,
               {
                 delivery_id: delivery.id,
                 location_id: {delivery.id.to_s => org.locations.last.id}
               },
               current_organization_id: org.id
        end

        it "assigns the delivery" do
          expect(session[:current_delivery_id]).to eql(delivery.id)
        end

        it "redirects to the products listing" do
          expect(response).to redirect_to([:products])
        end

        it "sets organization location to session" do
          expect(session[:current_location]).to eql(org.locations.last.id)
        end
      end

      context "and the location is not valid" do
        it "falls back to the shipping address" do
          post :create, {delivery_id: delivery.id, location_id: {delivery.id.to_s => 999}}, current_organization_id: org.id

          expect(response).to redirect_to([:products])
          expect(session[:current_delivery_id]).to eq(delivery.id)
          expect(session[:current_location]).to eq(org.shipping_location.id)
        end
      end
    end

    it "falls back to shipping location if a deleted location is selected" do
      loc = org.locations.first
      loc.soft_delete

      post :create, {delivery_id: delivery.id, location_id: {delivery.id.to_s => loc.id}}, current_organization_id: org.id

      expect(response).to redirect_to([:products])
      expect(session[:current_delivery_id]).to eq(delivery.id)
      expect(session[:current_location]).to eq(org.shipping_location.id)
    end
  end

  describe "new" do
    # Fixes https://www.pivotaltracker.com/story/show/73465524
    describe "switching markets" do
      let!(:other_market) { create(:market) }
      let!(:other_organization) { create(:organization, :multiple_locations, markets: [other_market], users: [user]) }

      it "clears out the organization if it isn't linked to the market" do
        get :new, {}, current_organization_id: other_organization.id
        expect(response).to redirect_to(new_sessions_organization_path(redirect_back_to: new_sessions_deliveries_url))
      end
    end
  end
end
