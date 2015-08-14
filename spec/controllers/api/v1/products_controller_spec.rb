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

      @banana_result = {"id"=>bananas.id, "name"=>"Bananas", "second_level_category_name"=>"Apples", "seller_name"=>"First Seller", "unit_with_description"=>"boxes", "short_description"=>"Empire state of mind", "long_description"=>nil, "cart_item"=>{"id"=>nil, "cart_id"=>1, "product_id"=>1, "quantity"=>0, "created_at"=>nil, "updated_at"=>nil, "total_price"=>0.0, "unit_sale_price"=>"3.0", "valid?"=>false, "destroyed?"=>false}, "cart_item_quantity"=>0, "max_available"=>150, "price_for_quantity"=>"$3.00", "total_price"=>"$0.00", "cart_item_persisted"=>false, "image_url"=>"http://market1.localtest.me/assets/default-product-image.png", "who_story"=>nil, "how_story"=>nil, "location_label"=>"Ann Arbor, MI", "location_map_url"=>"//api.tiles.mapbox.com/v3/localorbit.i0ao0akd/pin-s-circle(-86.109469,42.767645)/-86.109469,42.767645,9/310x225@2x.png", "prices"=>[{"sale_price"=>"$3.00", "organization_id"=>1, "formatted_units"=>"per box"}]}
      @banana2_result = {"id"=>bananas2.id, "name"=>"Bananas", "second_level_category_name"=>"Apples", "seller_name"=>"Second Seller", "unit_with_description"=>"boxes", "short_description"=>"Empire state of mind", "long_description"=>nil, "cart_item"=>{"id"=>nil, "cart_id"=>1, "product_id"=>2, "quantity"=>0, "created_at"=>nil, "updated_at"=>nil, "total_price"=>0.0, "unit_sale_price"=>"3.0", "valid?"=>false, "destroyed?"=>false}, "cart_item_quantity"=>0, "max_available"=>150, "price_for_quantity"=>"$3.00", "total_price"=>"$0.00", "cart_item_persisted"=>false, "image_url"=>"http://market1.localtest.me/assets/default-product-image.png", "who_story"=>nil, "how_story"=>nil, "location_label"=>"Ann Arbor, MI", "location_map_url"=>"//api.tiles.mapbox.com/v3/localorbit.i0ao0akd/pin-s-circle(-86.109469,42.767645)/-86.109469,42.767645,9/310x225@2x.png", "prices"=>[{"sale_price"=>"$3.00", "organization_id"=>1, "formatted_units"=>"per box"}]}
      @kale_result = {"id"=>kale.id, "name"=>"Kale", "second_level_category_name"=>"Apples", "seller_name"=>"First Seller", "unit_with_description"=>"boxes", "short_description"=>"Empire state of mind", "long_description"=>nil, "cart_item"=>{"id"=>nil, "cart_id"=>1, "product_id"=>3, "quantity"=>0, "created_at"=>nil, "updated_at"=>nil, "total_price"=>0.0, "unit_sale_price"=>"3.0", "valid?"=>false, "destroyed?"=>false}, "cart_item_quantity"=>0, "max_available"=>150, "price_for_quantity"=>"$3.00", "total_price"=>"$0.00", "cart_item_persisted"=>false, "image_url"=>"http://market1.localtest.me/assets/default-product-image.png", "who_story"=>nil, "how_story"=>nil, "location_label"=>"Ann Arbor, MI", "location_map_url"=>"//api.tiles.mapbox.com/v3/localorbit.i0ao0akd/pin-s-circle(-86.109469,42.767645)/-86.109469,42.767645,9/310x225@2x.png", "prices"=>[{"sale_price"=>"$3.00", "organization_id"=>nil, "formatted_units"=>"per box"}, {"sale_price"=>"$1.75", "organization_id"=>nil, "formatted_units"=>" 10+ boxes"}]}
    end

    def get_products(params)
      get :index, params
      JSON.parse(response.body)["products"]
    end


    it "returns a paginated list of products" do
      products = get_products(offset: 2)
      expect(products).to eq([@kale_result])
      products = get_products(offset: 1)
      expect(products).to eq([@banana2_result, @kale_result])
      products = get_products(offset: 0)
      expect(products).to eq([@banana_result, @banana2_result, @kale_result])
    end
  end
end