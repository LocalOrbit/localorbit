require "spec_helper"

describe Api::V1::OrderTemplatesController do
  describe "/index" do
    let(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:seller) { create(:organization, :seller, :single_location, name: 'First Seller') }
    let!(:second_seller) { create(:organization, :seller, :single_location, name: 'Second Seller') }

    let(:market) { create(:market, :with_addresses, organizations: [buyer, seller]) }
    let(:plan) {create(:plan, :localeyes)}
    let(:le_market) { create(:market, :with_addresses, organizations: [buyer, seller], plan: plan) }
    let!(:template2) {create(:order_template, market: market)}
    let!(:template) {create(:order_template, market: le_market)}

    describe "authorization" do
      it "does not allow calls from non localeyes markets" do
        switch_to_subdomain market.subdomain
        sign_in user
        get :index
        expect(response.status).to be 404
      end

      it "allows calls from localeyes markets" do
        switch_to_subdomain le_market.subdomain
        sign_in user
        get :index
        expect(response.status).to_not be 404
      end
    end
  end
end