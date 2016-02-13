require "spec_helper"

describe Admin::OrganizationsController do
  let(:org) { create(:organization) }
  let(:market) { create(:market, organizations: [org]) }
  let(:user) { create(:user) }

  before do
    switch_to_subdomain market.subdomain
  end

  describe "/show" do
    describe "a normal user" do
      before do
        sign_in user
      end

      it "cannot access an organization they don't belong to" do
        get :show, id: org.id
        expect(response).to be_not_found
      end

      it "can edit their organization" do
        user.organizations << org
        get :show, id: org.id
        expect(response).to be_success
      end
    end
  end

  describe "/new" do
    describe "a normal user" do
      before do
        sign_in user
      end

      it "cannot create a new organization" do
        get :new
        expect(response).to be_not_found
      end
    end
  end
end
