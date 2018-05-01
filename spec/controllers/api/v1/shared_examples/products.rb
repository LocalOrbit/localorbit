require 'controllers/api/v1/shared_contexts/products_search'

RSpec.shared_examples_for 'products search api' do

  context 'with an unauthenticated user' do
    describe 'GET index' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'with an authenticated user' do

    describe 'GET index' do

      include_context 'products search'

      before do
        switch_to_subdomain market.subdomain
        sign_in user
        session[:cart_id] = Cart.first.id
      end

      def get_products(params)
        get :index, params
        products = JSON.parse(response.body)['products']
        products.map { |general_product| general_product['available'].map { |product| product['id'] } }
      end

      it 'returns a paginated list of products' do
        products = get_products({ })
        expected_products = [[bananas.id], [bananas3.id, bananas2.id], [kale.id]]
        expect(products).to eq(expected_products)
        products = get_products(offset: 0)
        expect(products).to eq(expected_products)

        products = get_products(offset: 2)
        expect(products).to eq(expected_products.slice(2,1))

        products = get_products(offset: 1)
        expect(products).to eq(expected_products.slice(1,2))
      end

      it 'searches by text' do
        products = get_products(offset: 0, query: 'kale')
        expect(products).to eq([[kale.id]])
        products = get_products(offset: 0, query: 'xxxx')
        expect(products).to eq([])
        products = get_products(offset: 0, query: 'Apple')
        expect(products).to eq([[bananas.id], [bananas3.id, bananas2.id], [kale.id]])
        products = get_products(offset: 1, query: 'Apple')
        expect(products).to eq([[bananas3.id, bananas2.id], [kale.id]])
        products = get_products(offset: 0, query: 'First')
        expect(products).to eq([[bananas.id], [kale.id]])
        products = get_products(offset: 0, query: 'second')
        expect(products).to eq([[bananas3.id, bananas2.id]])
      end

      it 'filters results by seller' do
        products = get_products(offset: 0, query: 'banana', seller_ids: [])
        expect(products).to eq ([[bananas.id], [bananas3.id, bananas2.id]])
        products = get_products(offset: 0, query: 'banana', seller_ids: [bananas.organization_id])
        expect(products).to eq ([[bananas.id]])
        products = get_products(offset: 0, query: 'banana', seller_ids: [bananas2.organization_id])
        expect(products).to eq ([[bananas3.id, bananas2.id]])
        products = get_products(offset: 0, query: 'banana', seller_ids: [bananas.organization_id, bananas2.organization_id])
        expect(products).to eq ([[bananas.id], [bananas3.id, bananas2.id]])
      end

      it 'filters results by category and seller' do
        products = get_products(offset: 0, query: 'Apple', category_ids: [-1, -2])
        expect(products).to eq ([])
        products = get_products(offset: 0, query: 'Apple', seller_ids: [-1])
        expect(products).to eq ([])
        products = get_products(offset: 0, query: 'kale', seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.category_id])
        expect(products).to eq ([[kale.id]])
        products = get_products(offset: 0, query: 'kale', seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.top_level_category_id])
        expect(products).to eq ([[kale.id]])
        products = get_products(offset: 0, query: 'kale', seller_ids: [kale.organization_id, bananas2.organization_id], category_ids: [kale.second_level_category_id])
        expect(products).to eq ([[kale.id]])
      end

      it 'removes products when soft deleted' do
        products = get_products(offset: 0, query: 'kale', category_ids: [kale.category_id])
        expect(products).to eq ([[kale.id]])

        kale.soft_delete

        products = get_products(offset: 0, query: 'kale', category_ids: [kale.category_id])
        expect(products).to eq ([])
      end

    end
  end
end
