require "spec_helper"

describe ZendeskSSOController do
  let(:org) { create(:organization) }
  let!(:market) { create(:market, organizations: [org]) }
  let(:user) { create(:user, organizations: [org]) }

  before do
    switch_to_subdomain(market.subdomain)
  end

  describe "show" do
    context "a valid user" do
      before do
        sign_in(user)
      end

      it "redirects to zendesk" do
        get :show
        expect(response).to redirect_to(/localorbit\.zendesk\.com/)
      end
    end

    context "an invalid user" do
      it "redirects to the sign in page" do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
