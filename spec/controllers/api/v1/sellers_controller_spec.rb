require "spec_helper"

describe Api::V1::SellersController do
  describe "/index" do
    let(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:seller) { create(:organization, :seller, :single_location, name: 'First Seller') }
    let!(:second_seller) { create(:organization, :seller, :single_location, name: 'Second Seller') }

    let(:market) { create(:market, :with_addresses, organizations: [buyer, seller, second_seller]) }
    let(:other_market) { create(:market, :with_addresses, organizations: [buyer]) }

    def get_sellers()
      get :index
      sellers = JSON.parse(response.body)["sellers"]
      sellers.map { |seller| seller["id"] }
    end

    it "returns a list of sellers that can sell given a current market" do
      switch_to_subdomain market.subdomain
      sign_in user
      sellers = get_sellers()
      expect(sellers).to eq ([seller.id, second_seller.id])
    end

    it "doesn't return sellers that cannot sell for the current market" do
      switch_to_subdomain other_market.subdomain
      sign_in user
      sellers = get_sellers()
      expect(sellers).to eq ([])
    end
  end
end