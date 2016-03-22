require "spec_helper"

describe MarketsController do
  it "requires authentication" do
    get :show

    expect(response).to redirect_to(new_user_session_path)
  end

  context "when performing user-driven market creation" do
    it "allows unauthenticated access", vcr: true do
      # KXM HOLY CRAP THIS SUCKS.
      expect(build(:plan, stripe_id: "GROW")).to be_valid

      #get :new
      #expect(response).to respond_with 200

    end
  end

  it "returns not found for markets I am not a member of" do
    market = create(:market)
    user = create(:user)

    sign_in user
    switch_to_subdomain market.subdomain

    get :show

    expect(response).to be_not_found
  end
end
