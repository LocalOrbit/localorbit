require 'spec_helper'

RSpec.describe Admin::Financials::SellerPaymentGroupsController, type: :controller do
  include_context 'the mini market'

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in mary
  end

  describe 'GET show' do

    it 'returns success' do
      get :show, market_id: mini_market.id, seller_id: seller_organization.id
      expect(response).to have_http_status(:success)
    end

  end
end
