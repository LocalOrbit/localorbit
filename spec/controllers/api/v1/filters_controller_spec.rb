require "spec_helper"

describe Api::V1::FiltersController do
  describe "/index" do
    let(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:seller) { create(:organization, :seller, :single_location, name: 'First Seller') }
    let!(:second_seller) { create(:organization, :seller, :single_location, name: 'Second Seller') }

    let(:market) { create(:market, :with_addresses, organizations: [buyer, seller]) }
    let!(:delivery) { create(:delivery_schedule, market: market) }

    let(:category1) {create(:category, name: "Yellow Fruit")}
    let(:category2) {create(:category, name: "Leafy Greens", parent: create(:category, name: "Vegetables"))}
    let(:category3) {create(:category, name: "Pure Joy")}


    let!(:bananas) { create(:product, name: "Bananas", second_level_category_id: category1.id, organization: seller, delivery_schedules: [delivery]) }
    let!(:kale) { create(:product, name: "Kale", second_level_category_id: category2.id, organization: seller, delivery_schedules: [delivery]) }
    let!(:ice_cream) { create(:product, name: "Ice Cream", second_level_category_id: category3.id, organization: second_seller, delivery_schedules: [delivery]) }

    before do
      switch_to_subdomain market.subdomain
      sign_in user
    end

    def get_filters(params = nil)
      get :index, params
      filters = JSON.parse(response.body)["filters"]
      filters.map { |filter| filter["id"] }
    end

    describe "product categories" do
      it "returns a list of top level categories for a market when called with no parent_id" do
        filters = get_filters()
        expect(filters).to eq ([kale.top_level_category_id])
      end

      it "returns a list of children for a parent when called with a parent_id" do
        filters = get_filters({parent_id: kale.top_level_category_id})
        expect(filters).to eq ([kale.second_level_category_id])
      end
    end

    describe "suppliers" do
      it "returns the suppliers for a market when parent_id is set to 'suppliers'" do
        filters = get_filters(parent_id: "suppliers")
        expect(filters).to eq ([seller.id])
      end
    end
  end
end