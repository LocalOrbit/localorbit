require 'spec_helper'

describe Sessions::DeliveriesController do
  let!(:current_market) { create(:market, timezone: "US/Eastern") }
  let!(:schedule) {
    create(:delivery_schedule, market: current_market,
            order_cutoff: 6, seller_delivery_start: "6:00 am", seller_delivery_end: "10:00 am", day:4)
  }

  let!(:user) { create(:user, role: 'user') }
  let!(:org) { create(:organization, :multiple_locations, markets: [current_market], users: [user]) }

  before do
    sign_in(user)
    switch_to_subdomain current_market.subdomain
  end

  describe "/create" do
    let!(:delivery) { schedule.next_delivery }

    context "empty submission" do
      before do
        post :create, {delivery_id: ""}, {current_organization_id: org.id }
      end

      it "assigns a flash message" do
        expect(flash[:alert]).to eql("Please select a delivery")
      end
    end

    context "current_organization has one location" do
      let!(:org) { create(:organization, :single_location, markets: [current_market], users: [user]) }

      before do
        post :create,
             {
               delivery_id: delivery.id,
               location_id: {delivery.id.to_s => org.locations.first.id}
             }, {current_organization_id: org.id }
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
      before do
        post :create,
             {
                delivery_id: delivery.id,
                location_id: {delivery.id.to_s => org.locations.last.id}
             },
             {current_organization_id: org.id }
      end

      context "and the location is valid" do

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
        before do
          post :create,
              {
                  delivery_id: delivery.id,
                  location_id: {delivery.id.to_s => 999}
              },
              {current_organization_id: org.id }
        end

        it "assigns an error message and redirects" do
          expect(flash[:alert]).to eql("Please select a delivery")
          expect(response).to be_success
        end
      end
    end
  end
end
