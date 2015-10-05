require "spec_helper"

describe Api::V1::ProductsController do
  describe "/index" do
    let(:user) { create(:user) }
    let!(:buyer) { create(:organization, :single_location, :buyer, users: [user]) }
    let!(:seller) { create(:organization, :seller, :single_location, name: 'First Seller') }
    let!(:second_seller) { create(:organization, :seller, :single_location, name: 'Second Seller') }

    let(:market) { create(:market, :with_addresses, organizations: [buyer, seller, second_seller]) }
    let!(:delivery) { create(:delivery_schedule, market: market) }

    let(:market2) { create(:market, :with_addresses, organizations: [buyer, seller, second_seller]) }
    let!(:delivery2) { create(:delivery_schedule, market: market2) }

    # Products
    let!(:pound) { create(:unit, singular: "pound", plural: "pounds") }
    let!(:bananas) { create(:product, name: "Bananas", organization: seller, delivery_schedules: [delivery], unit: pound) }
    let!(:bananas_lot) { create(:lot, product: bananas) }
    let!(:bananas_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas, min_quantity: 1, organization: buyer)
    end

    let!(:bananas2) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:bananas2_lot) { create(:lot, product: bananas2) }
    let!(:bananas2_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas2, min_quantity: 1, organization: buyer)
    end

    let!(:crate) { create(:unit, singular: "crate", plural: "crates") }
    let!(:bananas3) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery],
                             unit: crate, general_product: bananas2.general_product) }
    let!(:bananas3_lot) { create(:lot, product: bananas3) }
    let!(:bananas3_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas3, min_quantity: 1, organization: buyer)
    end

    let!(:kale) { create(:product, name: "Kale", organization: seller, delivery_schedules: [delivery]) }
    let!(:kale_lot) { create(:lot, product: kale) }
    let!(:kale_price_buyer_base) do
      create(:price, :past_price, market: market, product: kale, min_quantity: 1)
      create(:price, :past_price, market: market, product: kale, min_quantity: 10, sale_price: 1.75)
    end

    let!(:cart) { create(:cart, market: market, organization: buyer, user: user, delivery: delivery.next_delivery) }

    # products without inventory should not appear in search results
    let!(:bananas4) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:bananas4_lot) { create(:lot, product: bananas4, quantity: 0) }
    let!(:bananas4_price_buyer_base) do
      create(:price, :past_price, market: market, product: bananas4, min_quantity: 1, organization: buyer)
    end

    # products for another market should not appear in search results
    let!(:bananas5) { create(:product, name: "Bananas", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:bananas5_lot) { create(:lot, product: bananas5) }
    let!(:bananas5_price_buyer_base) do
      create(:price, :past_price, market: market2, product: bananas5, min_quantity: 1, organization: buyer)
    end

    before do
      switch_to_subdomain market.subdomain
      sign_in user
      session[:cart_id] = Cart.first.id
    end

    def get_products(params)
      get :index, params
      products = JSON.parse(response.body)["products"]
      products.map { |general_product| general_product["available"].map { |product| product["id"] } }
    end


    it "returns a paginated list of products" do
      # products = get_products(offset: 2)
      # expect(products).to eq([kale.id])
      # products = get_products(offset: 1)
      # expect(products).to eq([bananas2.id, kale.id])
      # products = get_products(offset: 0)
      # expect(products).to eq([bananas.id, bananas2.id, kale.id])
      products = get_products(offset: 2)
      expect(Set.new(products)).to eq(Set.new([kale.id]))
      products = get_products(offset: 1)
      expect(Set.new(products)).to eq(Set.new([bananas2.id, kale.id]))
      products = get_products(offset: 0)
      expect(Set.new(products)).to eq(Set.new([bananas.id, bananas2.id, kale.id])) # sets because of varying order,
    end

    it "searches by text" do
      products = get_products(offset: 0, query: "kale")
      expect(products).to eq([[kale.id]])
      products = get_products(offset: 0, query: "xxxx")
      expect(products).to eq([])
      products = get_products(offset: 0, query: "Apple")
      expect(products).to eq([[bananas.id], [bananas3.id, bananas2.id], [kale.id]])
      products = get_products(offset: 1, query: "Apple")
      expect(products).to eq([[bananas3.id, bananas2.id], [kale.id]])
      products = get_products(offset: 0, query: "First Seller")
      expect(products).to eq([[bananas.id], [kale.id]])
      products = get_products(offset: 0, query: "second s")
      expect(products).to eq([[bananas3.id, bananas2.id]])
    end

    it "filters results by seller" do
      products = get_products(offset: 0, query: "banana", seller_ids: [])
      expect(products).to eq ([[bananas.id], [bananas3.id, bananas2.id]])
      products = get_products(offset: 0, query: "banana", seller_ids: [bananas.organization_id])
      expect(products).to eq ([[bananas.id]])
      products = get_products(offset: 0, query: "banana", seller_ids: [bananas2.organization_id])
      expect(products).to eq ([[bananas3.id, bananas2.id]])
      products = get_products(offset: 0, query: "banana", seller_ids: [bananas.organization_id, bananas2.organization_id])
      expect(products).to eq ([[bananas.id], [bananas3.id, bananas2.id]])
    end

    it "filters results by category and seller" do
      products = get_products(offset: 0, query: "Apple", category_ids: [-1, -2])
      expect(products).to eq ([])
      products = get_products(offset: 0, query: "Apple", seller_ids: [-1])
      expect(products).to eq ([])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.category_id])
      expect(products).to eq ([[kale.id]])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.top_level_category_id])
      expect(products).to eq ([[kale.id]])
      products = get_products(offset: 0, query: "kale", seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.second_level_category_id])
      expect(products).to eq ([[kale.id]])
    end
  end
end
