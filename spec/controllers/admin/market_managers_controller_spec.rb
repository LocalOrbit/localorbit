require 'spec_helper'

describe Admin::MarketManagersController do
  let!(:user) { create(:user, :admin) }
  let!(:market) { create(:market) }
  let(:interactor_context) { {market: market, email: 'a-user@example.com', inviter: user} }

  describe '#create' do
    it_behaves_like "admin only action", lambda { post :create, market_id: market.id, email: 'a-user@example.com' }

    describe 'on success' do
      before(:each) do
        sign_in user
      end

      it 'calls the AddMarketManager interactor and redirects to the managers page' do
        result = double(Object, :"success?" => true)
        expect(AddMarketManager).to receive(:perform).with(interactor_context).and_return(result)

        post :create, market_id: market.id, email: 'a-user@example.com'

        expect(request).to redirect_to("/admin/markets/#{market.id}/managers")
      end
    end

    describe 'on failure' do
      before(:each) do
        sign_in user
      end

      it 'calls the AddMarketManager interactor and renders the new view' do
        result = double(Object, :"success?" => false)
        expect(AddMarketManager).to receive(:perform).with(interactor_context).and_return(result)

        post :create, market_id: market.id, email: 'a-user@example.com'

        expect(request).to render_template("admin/market_managers/new")
      end
    end
  end
end
