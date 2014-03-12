require 'spec_helper'

describe Sessions::OrganizationsController do
  let(:user) { create(:user) }
  let!(:org) { create(:organization) }
  let!(:org2) {create(:organization) }

  let(:valid_session) {}
  let(:user) { create(:user) }

  before do
    org.users << user
    org.save!
    sign_in(user)
  end

  context "when no organization has been submitted" do
    before do
      post :create, { organization: {id: ""}}, valid_session
    end

    it "displays an error message" do
      expect(flash[:alert]).to eql("Please select an organization")
    end
  end

  context "given an invalid organization" do
    before do
      post :create, { organization: {id: org2.id}}, valid_session
    end

    it "displays an error message" do
      expect(flash[:alert]).to eql("Please select a different organization")
    end
  end

  context "submitting an organization the user manages" do
    before do
      post :create, { organization: {id: org.id}}, valid_session
    end

    it "assigns the organization_id in session" do
      expect(session[:current_organization_id]).to eql(org.id)
    end

    it "redirects to products" do
      expect(response).to redirect_to([:products])
    end
  end
end
