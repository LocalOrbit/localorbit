require "spec_helper"

describe Api::V1::ProductsController do
  describe "/index" do
    let(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:seller) { create(:organization, :seller, :single_location, name: 'First Seller') }
    let!(:second_seller) { create(:organization, :seller, :single_location, name: 'Second Seller') }

    let(:market) { create(:market, :with_addresses, organizations: [buyer, seller, second_seller]) }
    let!(:delivery) { create(:delivery_schedule, market: market) }

    # Products
    let!(:bananas) { create(:product, name: "Bananas", organization: seller, delivery_schedules: [delivery]) }
    let!(:bananas_lot) { create(:lot, product: bananas) }
    let!(:bananas_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer)
    end

    let!(:bananas2) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery]) }
    let!(:bananas2_lot) { create(:lot, product: bananas2) }
    let!(:bananas2_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas2, min_quantity: 1, organization: buyer)
    end

    let!(:kale) { create(:product, name: "Kale", organization: seller, delivery_schedules: [delivery]) }
    let!(:kale_lot) { create(:lot, product: kale) }
    let!(:kale_price_buyer_base) do
      create(:price, :past_price, market: market, product: kale, min_quantity: 1)
      create(:price, :past_price, market: market, product: kale, min_quantity: 10, sale_price: 1.75)
    end

    let!(:cart)      { create(:cart, market: market, organization: buyer, user: user, delivery: delivery.next_delivery) }

    before do
      switch_to_subdomain market.subdomain
      sign_in user
      session[:cart_id] = Cart.first.id
    end

    def get_products(params)
      get :index, params
      products = JSON.parse(response.body)["products"]
      products.map { |product| product["id"] }
    end


    it "returns a paginated list of products" do
      products = get_products(offset: 2)
      expect(Set.new(products)).to eq(Set.new([kale.id]))
      products = get_products(offset: 1)
      expect(Set.new(products)).to eq(Set.new([bananas2.id, kale.id]))
      products = get_products(offset: 0)
      expect(Set.new(products)).to eq(Set.new([bananas.id, bananas2.id, kale.id])) # sets because of varying order, poss fix.
    end

    it "searches by text" do
      products = get_products(offset: 0, query: "kale")
      expect(products).to eq([kale.id])
      products = get_products(offset: 0, query: "xxxx")
      expect(products).to eq([])
      products = get_products(offset: 0, query: "Apple")
      expect(products).to eq([bananas.id, bananas2.id, kale.id])
      products = get_products(offset: 1, query: "Apple")
      expect(products).to eq([bananas2.id, kale.id])
      products = get_products(offset: 0, query: "First S")
      expect(products).to eq([bananas.id, kale.id])
    end

    it "filters results by category and seller" do
      products = get_products(offset: 0, query: "Apple", category_ids: [-1, -2])
      expect(products).to eq ([])
      products = get_products(offset: 0, query: "Apple", seller_ids: [-1])
      expect(products).to eq ([])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.category_id])
      expect(products).to eq ([kale.id])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.top_level_category_id])
      expect(products).to eq ([kale.id])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.second_level_category_id])
      expect(products).to eq ([kale.id])
    end
  end
end