require "spec_helper"

module Admin
  describe LocationsController do
    let(:org)                       { create(:organization, :buyer) }
    let(:location)                  { create(:location, organization: org) }
    let(:market)                    { create(:market, organizations: [org]) }
    let(:admin)                     { create(:user, :admin) }
    let(:non_member)                { create(:user, :market_manager) }
    let(:market_manager_non_member) { create(:user, :market_manager) }

    let(:organization) do
      create(:user, :buyer).tap do |user|
        user.organizations << org
      end
    end

    let(:member) do
      create(:user, :buyer).tap do |user|
        user.organizations << org
      end
    end

    let(:market_manager_member) do
      create(:user, :market_manager).tap do |market_manager|
        market_manager.organizations << org
      end
    end

    before do
      switch_to_subdomain market.subdomain
    end

    describe "#index" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        get :index, organization_id: org.id
      }
    end

    describe "#new" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        get :new, organization_id: org.id
      }
    end

    describe "#create succeeds" do
      before do
        allow_any_instance_of(Location).to receive(:save) { true }
        allow(controller).to receive(:location_params)
      end

      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        post :create, organization_id: org.id
      }
    end

    describe "#create fails" do
      before do
        sign_in admin
        allow_any_instance_of(Location).to receive(:save) { false }
        allow(controller).to receive(:location_params)
      end

      it "renders the new page" do
        post :create, organization_id: org.id
        expect(response).to be_success
        expect(flash[:alert]).to eq("Could not save address")
      end
    end

    describe "#edit" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        get :edit, organization_id: org.id, id: location.id
      }
    end

    describe "#update succeeds" do
      before do
        allow_any_instance_of(Location).to receive(:update_attributes) { true }
        allow(controller).to receive(:location_params)
      end

      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        patch :update, organization_id: org.id, id: location.id
      }
    end

    describe "#update fails" do
      before do
        sign_in admin
        allow_any_instance_of(Location).to receive(:update_attributes) { false }
        allow(controller).to receive(:location_params)
      end

      it "renders the new page" do
        patch :update, organization_id: org.id, id: location.id
        expect(response).to be_success
        expect(flash[:alert]).to eq("Could not update address")
      end
    end

    describe "#update_defaults" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        put :update_default,
          organization_id: org.id,
          default_billing_id: location.id,
          default_shipping_id: location.id
      }
    end

    describe "#destroy" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        delete :destroy, organization_id: org.id, location_ids: []
      }
    end

    describe "#destroy resets defaults" do
      it "makes the first remaining location the default" do
        sign_in member

        location.reload
        expect(location).to be_default_billing
        expect(location).to be_default_shipping

        location2 = create(:location, organization: org)
        expect(location2).not_to be_default_billing
        expect(location2).not_to be_default_shipping

        delete :destroy, organization_id: org.id, location_ids: [location.id]
        location.reload
        location2.reload

        expect(location2).to be_default_billing
        expect(location2).to be_default_shipping
      end

      it "marks new location default after destroying all" do
        sign_in member
        delete :destroy, organization_id: org.id, location_ids: [location.id]
        new_location = create(:location, organization: org)
        new_location.reload

        expect(new_location).to be_default_billing
        expect(new_location).to be_default_shipping
      end
    end
  end
end
