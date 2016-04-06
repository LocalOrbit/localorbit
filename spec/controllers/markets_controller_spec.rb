require "spec_helper"

describe MarketsController do
  let(:org1) { create(:organization) }
  let(:user) { create(:user, organizations: [org1]) }
  before(:each) do
    sign_out user
  end

  context "when displaying market details" do
    it "requires authentication" do
      get :show
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when navigating to the success page" do
    it "allows unauthenticated access" do
      get :success
      expect(response).to be_success
    end

    it "renders the correct layout" do
      get :success
      # Significant because the layout is different, yo.
      expect(response).to render_template(layout: "website-bridge")
    end

    it "renders the correct view" do
      get :success
      # Not particularly significant, but look! I can test it!
      expect(response).to render_template(:success)
    end
  end

  context "when performing user-driven market creation" do
    # KXM This is junk for the most part...
    it "allows unauthenticated access", vcr: true do
      plan = double(:plan, id: 2, stripe_id: "GROW")
      expect(build(:plan, stripe_id: "GROW")).to be_valid
      expect(build(:market, payment_provider: "stripe", pending: true, self_directed_creation: true, plan_id: plan.id)).to be_valid

      # market = double(:market, payment_provider: "stripe", pending: true, self_directed_creation: true, plan_id: plan.id)

      # get :new
      # expect(response).to respond_with 200

    end
  end

  context "when the user-driven market is submitted" do
    xit "notifies user of successful submission", vcr: true do
      
      # post :create, market: market, market_params: market_p, billing_params: billing_p, subscription_params: subscription_p, bank_account_params: bank_account_p, :amount => subscription_p[:plan_price], flash: {}
      # post :create, market_params: market_params, billing_params: billing_params, subscription_params: subscription_params, bank_account_params: bank_account_params, :amount => subscription_params[:plan_price], flash: {}


      expect(flash[:notice]).to match(/^Your request for a new Market will be processed shortly./)
      expect(response).to redirect_to '/success'
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
