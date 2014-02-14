require "spec_helper"

module Admin
  describe LocationsController do
    let(:organization)              { create(:organization) }
    let(:location)                  { create(:location, organization: organization) }
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

    describe "#create" do
      before do
        Location.any_instance.stub(:save) { true }
        controller.stub(:location_params)
      end

      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        post :create, organization_id: organization.id
      }
    end

    describe "#edit" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        get :edit, organization_id: organization.id, id: location.id
      }
    end

    describe "#update" do
      before do
        Location.any_instance.stub(:update_attributes) { true }
        controller.stub(:location_params)
      end

      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        patch :update, organization_id: organization.id, id: location.id
      }
    end

    describe "#update_defaults" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        put :update_defaults, { organization_id: organization.id,
          default_billing_id: location.id, default_shipping_id: location.id
        }
      }
    end

    describe "#destroy" do
      it_behaves_like "an action restricted to admin, market manager, member", lambda {
        delete :destroy, organization_id: organization.id, location_ids: []
      }
    end
  end
end
