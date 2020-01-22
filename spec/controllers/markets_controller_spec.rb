require "spec_helper"

describe MarketsController do
  let(:org1) { create(:organization) }
  let(:user) { create(:user, organizations: [org1]) }

  before :all do VCR.turn_off! end
  after :all do VCR.turn_on! end

  before(:each) do
    sign_out user
  end

  describe 'GET new' do
    it 'with no plan ID returns 404' do
      get :new
      expect(response).to be_not_found
    end
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



  it "returns not found for markets I am not a member of" do
    market = create(:market)
    user = create(:user)

    sign_in user
    switch_to_subdomain market.subdomain

    get :show

    expect(response).to be_not_found
  end
end
