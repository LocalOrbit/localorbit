require "spec_helper"

describe "Load list" do
  let!(:market)                   { create(:market) }
  let!(:seller)                   { create(:organization, :seller, :single_location, markets: [market], name: "First Seller") }
  let!(:seller2)                  { create(:organization, :seller, :single_location, markets: [market], name: "Second Seller") }
  let!(:seller3)                  { create(:organization, :seller, :single_location, markets: [market], name: "Third Seller") }
  let!(:seller_product)           { create(:product, :sellable, name: "Beans", organization: seller, code: "nifty-product-code") }
  let!(:seller_product2)          { create(:product, :sellable, name: "Avocado", organization: seller, code: "nifty-product-code") }
  let!(:seller3_product)          { create(:product, :sellable, name: "Apples", organization: seller, code: "nifty-product-code") }
  let!(:delivered_product)        { create(:product, :sellable, organization: seller, code: "nifty-product-code") }
  let!(:seller2_product)          { create(:product, :sellable, name: "Sprouts", organization: seller2, code: "nifty-product-code") }

  let!(:friday_delivery_schedule) { create(:delivery_schedule, market: market, day: 5) }
  let!(:friday_delivery)          { create(:delivery, delivery_schedule: friday_delivery_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014")) }

  let!(:buyer1)                   { create(:organization, :buyer, :single_location, markets: [market], name: "First Buyer") }
  let!(:buyer2)                   { create(:organization, :buyer, :single_location, markets: [market], name: "Second Buyer") }

  let!(:seller_order_item)        { create(:order_item, product: seller_product, quantity: 1) }
  let!(:seller_order_item_prod2)  { create(:order_item, product: seller_product2, quantity: 2) }
  let!(:seller_order)             { create(:order, items: [seller_order_item], organization: buyer1, market: market, delivery: friday_delivery) }
  let!(:seller_order_item2)       { create(:order_item, product: seller_product2, quantity: 1) }
  let!(:seller_order2)            { create(:order, items: [seller_order_item2], organization: buyer1, market: market, delivery: friday_delivery) }
  let!(:delivered_order_item)     { create(:order_item, product: delivered_product, quantity: 1, delivery_status: "delivered") }
  let!(:delivered_order)          { create(:order, items: [delivered_order_item], organization: buyer1, market: market, delivery: friday_delivery) }

  let!(:seller2_order_item)       { create(:order_item, product: seller2_product, quantity: 2) }
  let!(:seller2_order)            { create(:order, items: [seller2_order_item], organization: buyer2, market: market, delivery: friday_delivery) }

  let!(:lot1)                     { create(:lot, product: seller3_product, number: "123", quantity: 15) }
  let!(:order_item_lot1)          { create(:order_item_lot, order_item: seller3_order_item, lot: lot1, quantity: 15) }
  let!(:lot2)                     { create(:lot, product: seller3_product, number: "456", quantity: 5) }
  let!(:order_item_lot2)          { create(:order_item_lot, order_item: seller3_order_item, lot: lot2, quantity: 3) }

  let!(:seller3_order_item)       { create(:order_item, product: seller3_product, quantity: 18) }
  let!(:seller3_order)            { create(:order, items: [seller3_order_item], organization: buyer1, market: market, delivery: friday_delivery) }

  before do
    Timecop.travel("May 5, 2014")
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  after do
    Timecop.return
  end

  context "as a market manager" do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

    context "orders for multiple sellers" do
      before do
        visit admin_delivery_tools_load_list_path(friday_delivery.deliver_on, market_id: market.id)
      end

      it "shows undelivered items" do
        expect(Dom::Admin::LoadListItem.find_by_product(seller_product.name)).to be
        expect(Dom::Admin::LoadListItem.find_by_product(seller2_product.name)).to be
      end

      it "does not show delivered items" do
        expect(Dom::Admin::LoadListItem.find_by_product(delivered_product.name)).to be_nil
      end
    end
  end
end
