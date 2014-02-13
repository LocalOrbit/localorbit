require "spec_helper"

module Admin
  describe LocationsController do
    let(:organization) { create(:organization) }
    let(:admin)        { create(:user, :admin) }
    let(:non_member)   { create(:user) }

    let(:member) do
      create(:user).tap do |user|
        user.organizations << organization
      end
    end

    let(:market_manager) do
      create(:user, :market_manager).tap do |market_manager|
        market_manager.organizations << organization
      end
    end

    describe "#index" do
      it "prevents access when not signed in" do
        get :index, organization_id: organization.id

        expect(response).to redirect_to(new_user_session_path)
      end

      it "prevents access when not a member of the organization" do
        sign_in non_member

        get :index, organization_id: organization.id

        expect(response).to be_not_found
      end
    end

    describe "#new" do
      it "prevents access when not signed in" do
        get :new, organization_id: organization.id

        expect(response).to redirect_to(new_user_session_path)
      end

      it "prevents access when not a member of the organization" do
        sign_in non_member

        get :new, organization_id: organization.id

        expect(response).to be_not_found
      end

      it "prevents access when not an admin nor market manager" do
        sign_in member

        get :new, organization_id: organization.id

        expect(response).to be_not_found
      end
    end

    describe "#create" do
      it "prevents access when not signed in" do
        post :create, organization_id: organization.id

        expect(response).to redirect_to(new_user_session_path)
      end

      it "prevents access when not a member of the organization" do
        sign_in non_member

        post :create, organization_id: organization.id

        expect(response).to be_not_found
      end

      it "prevents access when not an admin nor market manager" do
        sign_in member

        post :create, organization_id: organization.id

        expect(response).to be_not_found
      end
    end

    describe "#destroy" do
      it "prevents access when not signed in" do
        delete :destroy, organization_id: organization.id

        expect(response).to redirect_to(new_user_session_path)
      end

      it "prevents access when not a member of the organization" do
        sign_in non_member

        delete :destroy, organization_id: organization.id

        expect(response).to be_not_found
      end

      it "prevents access when not an admin nor market manager" do
        sign_in member

        delete :destroy, organization_id: organization.id

        expect(response).to be_not_found
      end

      it "" do
        sign_in admin
        delete :destroy, organization_id: organization.id
      end
    end
  end
end
