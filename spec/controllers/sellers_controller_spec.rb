require 'spec_helper'

describe SellersController do

  include_context 'the mini market'
  let!(:location) { create(:location, organization: buyer_organization) }

  before do
    switch_to_subdomain mini_market.subdomain
    sign_in barry
  end

  describe '#index' do
    before do
      get :index
    end

    it 'responds successfully' do
      expect(response.status).to eq(200)
    end
  end

  describe '#show' do
    before do
      get :show, id: seller.id
    end

    context 'seller with show_profile = false' do
      let(:seller) { create(:organization, :seller, name: 'No Show Farm', show_profile: false, markets:[mini_market]) }

      it 'responds successfully' do
        expect(response.status).to eq(200)
      end
    end

    context 'inactive seller with show_profile = true' do
      let(:seller) { create(:organization, :seller, name: 'Inactive Farm', active: false, show_profile: true, markets:[mini_market]) }

      it 'responds not found' do
        expect(response.status).to eq(404)
      end
    end
  end
end