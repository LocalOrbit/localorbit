require "spec_helper"

describe Admin::FreshSheetsController do
  let(:market_manager)     { create(:user, :market_manager) }
  let(:market)             { market_manager.managed_markets.first }

  before do
    switch_to_subdomain market.subdomain
  end

  context "/show" do
    it_behaves_like "an action restricted to admin or market manager", lambda { get :show }

    context "without a delivery schedule" do
      before do
        sign_in market_manager
      end

      it "redirects to new delivery schedule" do
        get :show

        expect(response).to redirect_to(new_admin_market_delivery_schedule_path(market))
      end
    end

    context "without products" do
      let!(:delivery_schedule) { create(:delivery_schedule, market: market) }

      before do
        sign_in market_manager
      end

      it "renders a no products warning message" do
        get :show

        expect(response).to be_success
        expect(response).to render_template("admin/fresh_sheets/no_products")
      end
    end

    context "with a delivery schedule and products" do
      let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
      let!(:seller) { create(:organization, :seller, markets: [market]) }
      let!(:product) { create(:product, :sellable, organization: seller) }

      before do
        sign_in market_manager
      end

      it "renders the show page" do
        get :show

        expect(response).to be_success
        expect(response).to render_template("admin/fresh_sheets/show")
      end
    end
  end
end
