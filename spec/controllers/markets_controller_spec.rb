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
    # See table_tents_and_posters_controller_spec for examples of Interactor, delayed_jobs, etc...

    # results = double(Interactor)
    # results.stub(:success).and_return(true)
    # binding.pry
    
    # post :create

    # expect(flash[:notice]).to match(/^Your request for a new Market will be processed shortly./)
    # expect(response).to redirect_to '/success'
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
