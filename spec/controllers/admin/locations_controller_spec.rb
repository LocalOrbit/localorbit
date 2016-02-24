require "spec_helper"

module Admin
  describe LocationsController do
    let(:organization)              { create(:organization, :seller) }
    let(:location)                  { create(:location, organization: organization) }
    let(:market)                    { create(:market, organizations: [organization]) }
    let(:admin)                     { create(:user, :admin) }
    let(:non_member)                { create(:user) }
    let(:market_manager_non_member) { create(:user, :market_manager) }

    let(:member) do
      create(:user).tap do |user|
        user.organizations << organization
      end
    end

    let(:market_manager_member) do
      create(:user, :market_manager).tap do |market_manager|
        market_manager.organizations << organization
      end
    end

    before do
      switch_to_subdomain market.subdomain
    end

    describe "#index" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        get :index, organization_id: organization.id
      }
    end

    describe "#new" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        get :new, organization_id: organization.id
      }
    end

    describe "#create succeeds" do
      before do
        allow_any_instance_of(Location).to receive(:save) { true }
        allow(controller).to receive(:location_params)
      end

      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        post :create, organization_id: organization.id
      }
    end

    describe "#create fails" do
      before do
        sign_in admin
        allow_any_instance_of(Location).to receive(:save) { false }
        allow(controller).to receive(:location_params)
      end

      it "renders the new page" do
        post :create, organization_id: organization.id
        expect(response).to be_success
        expect(flash[:alert]).to eq("Could not save address")
      end
    end

    describe "#edit" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        get :edit, organization_id: organization.id, id: location.id
      }
    end

    describe "#update succeeds" do
      before do
        allow_any_instance_of(Location).to receive(:update_attributes) { true }
        allow(controller).to receive(:location_params)
      end

      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        patch :update, organization_id: organization.id, id: location.id
      }
    end

    describe "#update fails" do
      before do
        sign_in admin
        allow_any_instance_of(Location).to receive(:update_attributes) { false }
        allow(controller).to receive(:location_params)
      end

      it "renders the new page" do
        patch :update, organization_id: organization.id, id: location.id
        expect(response).to be_success
        expect(flash[:alert]).to eq("Could not update address")
      end
    end

    describe "#update_defaults" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        put :update_default,
          organization_id: organization.id,
          default_billing_id: location.id,
          default_shipping_id: location.id
      }
    end

    describe "#destroy" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        delete :destroy, organization_id: organization.id, location_ids: []
      }
    end
  end
end
