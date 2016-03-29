require "spec_helper"

describe Admin::MarketStripeController do
  let(:admin)  { create(:user, :admin) }
  let(:market) { create(:market) }

  describe "#show" do
    it_behaves_like "admin only action", lambda { get :show, market_id: market.id }
  end
end
