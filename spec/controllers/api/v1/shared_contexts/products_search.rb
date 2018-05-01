RSpec.shared_context 'products search' do
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

    let!(:promotion) { create(:promotion, :active, product: bananas, market: market, body: "Big savings!") }

    let!(:cart) { create(:cart, market: market, organization: buyer, user: user, delivery: delivery.next_delivery) }

    # products without inventory should not appear in search results
    let!(:beans) { create(:product, name: "Beans", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:beans_lot) { create(:lot, product: beans, quantity: 0) }
    let!(:beans_price_buyer_base) do
      create(:price, :past_price, market: market, product: beans, min_quantity: 1, organization: buyer)
    end

    # products for another market should not appear in search results
    let!(:peanuts) { create(:product, name: "Peanuts", organization: second_seller, delivery_schedules: [delivery], unit: pound) }
    let!(:peanuts_lot) { create(:lot, product: peanuts) }
    let!(:peanuts_price_buyer_base) do
      create(:price, :past_price, market: market2, product: peanuts, min_quantity: 1, organization: buyer)
    end
end
