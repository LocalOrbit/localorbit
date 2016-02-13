require "spec_helper"

describe Admin::FeesController do
  let!(:organization) { create(:organization, :market) }

  describe "#show" do
    it_behaves_like "admin only action", lambda { get :show, organization_id: organization.id }
  end

  describe "#update" do
    it_behaves_like "admin only action", lambda { post :update, organization_id: organization.id, market: {local_orbit_seller_fee: "1", local_orbit_market_fee: "2", market_seller_fee: "3", credit_card_seller_fee: "4", credit_card_market_fee: "5", payment_fees_paid_by: 'seller'} }
  end
end
