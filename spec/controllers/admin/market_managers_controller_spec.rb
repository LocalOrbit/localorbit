require "spec_helper"

describe Admin::MarketManagersController do
  let(:market_manager)     { create(:user, :market_manager) }
  let(:market)             { market_manager.managed_markets.first }
  let(:interactor_context) { {market: market, email: "a-user@example.com", inviter: market_manager} }

  describe "#create" do
    before(:each) do
      switch_to_subdomain market.subdomain
    end

    it_behaves_like "an action restricted to admin or market manager", lambda { post :create, market_id: market.id, email: "a-user@example.com" }

    describe "on success" do
      before(:each) do
        sign_in market_manager
      end

      it "calls the AddMarketManager interactor and redirects to the managers page" do
        result = double(Object, :"success?" => true)
        expect(AddMarketManager).to receive(:perform).with(interactor_context).and_return(result)

        post :create, market_id: market.id, email: "a-user@example.com"

        expect(request).to redirect_to("/admin/markets/#{market.id}/managers")
      end
    end

    describe "on failure" do
      before(:each) do
        sign_in market_manager
      end

      it "calls the AddMarketManager interactor and renders the new view" do
        result = double(Object, :"success?" => false)
        expect(AddMarketManager).to receive(:perform).with(interactor_context).and_return(result)

        post :create, market_id: market.id, email: "a-user@example.com"

        expect(request).to redirect_to("/admin/markets/#{market.id}/managers")
        expect(flash[:alert]).to eq("a-user@example.com could not be invited.")
      end
    end
  end
end
