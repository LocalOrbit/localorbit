require "spec_helper"

describe Api::V1::CategoriesController do
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


    let!(:bananas) { create(:product, name: "Bananas", category: category1, organization: seller, delivery_schedules: [delivery]) }
    let!(:kale) { create(:product, name: "Kale", category: category2, organization: seller, delivery_schedules: [delivery]) }
    let!(:ice_cream) { create(:product, name: "Ice Cream", category: category3, organization: second_seller, delivery_schedules: [delivery]) }

    before do
      switch_to_subdomain market.subdomain
      sign_in user
    end

    def get_categories(params = nil)
      get :index, params
      categories = JSON.parse(response.body)["categories"]
      categories.map { |category| category["id"] }
    end

    it "returns a list of top level categories for a market" do
      categories = get_categories()
      expect(categories).to eq ([category1.id, category2.id])
    end

    it "returns a list of children for a parent" do
      categories = get_categories({parent_id: category2.parent_id})
      expect(categories).to eq ([category2.id])
    end
  end
end