require "spec_helper"

describe Sessions::OrganizationsController do
  let!(:org) { create(:organization) }
  let!(:org2) { create(:organization) }
  let(:market) { create(:market, organizations: [org]) }
  let(:user) { create(:user, organizations: [org]) }

  let(:valid_session) {}

  before do
    switch_to_subdomain market.subdomain
    sign_in(user)
  end

  context "when no organization has been submitted" do
    before do
      post :create, {org_id: ""}, valid_session
    end

    it "displays an error message" do
      expect(flash[:alert]).to eql("Please select an organization")
    end
  end

  context "given an invalid organization" do
    before do
      post :create, {org_id: org2.id}, valid_session
    end

    it "displays an error message" do
      expect(flash[:alert]).to eql("Please select an organization")
    end
  end

  context "submitting an organization the user manages" do
    before do
      post :create, {org_id: org.id}, valid_session
    end

    it "assigns the organization_id in session" do
      expect(session[:current_organization_id]).to eql(org.id)
    end

    it "redirects to products" do
      expect(response).to redirect_to([:products])
    end
  end
end
