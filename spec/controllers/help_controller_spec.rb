require 'spec_helper'

describe HelpController do
  let(:admin)   { create(:user, :admin) }
  let!(:market) { create(:market) }
  let(:org1)    { create(:organization, markets: [market]) }
  let(:user)    { create(:user, organizations: [org1]) }

  before :all do VCR.turn_off! end
  after :all do VCR.turn_on! end

  describe 'GET /help' do
    it 'on app domain returns 404' do
      sign_in(admin)
      switch_to_main_domain()
      get :show
      expect(response).to be_not_found
      sign_out(admin)
    end

    it 'returns successfully' do
      sign_in(user)
      switch_to_subdomain(market.subdomain)
      get :show
      expect(response).to be_success
      sign_out(user)
    end
  end
end