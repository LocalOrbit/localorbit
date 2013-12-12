require 'spec_helper'

describe Admin::MarketManagersController do
  let!(:market) { FactoryGirl.create(:market) }

  before(:each) do
    sign_in FactoryGirl.create(:user)
  end

  describe '#create' do
    describe 'on success' do
      it 'calls the AddMarketManager interactor and redirects to the managers page' do
        result = double(Object, :"success?" => true)
        expect(AddMarketManager).to receive(:perform).with(market: market, email: 'a-user@example.com').and_return(result)

        post :create, market_id: market.id, email: 'a-user@example.com'

        expect(request).to redirect_to("/admin/markets/#{market.id}/managers")
      end
    end

    describe 'on failure' do
      it 'calls the AddMarketManager interactor and renders the new view' do
        result = double(Object, :"success?" => false)
        expect(AddMarketManager).to receive(:perform).with(market: market, email: 'a-user@example.com').and_return(result)

        post :create, market_id: market.id, email: 'a-user@example.com'

        expect(request).to render_template("admin/market_managers/new")
      end
    end
  end
end
