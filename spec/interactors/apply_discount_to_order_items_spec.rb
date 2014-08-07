require "spec_helper"

describe ApplyDiscountToOrderItems do
  let!(:seller1)               { create(:organization, :seller) }
  let!(:seller1_product)       { create(:product, organization: seller1) }
  let!(:seller1_product_price) { create(:price, product: seller1_product, sale_price: 2.00) }
  let!(:seller1_product_lot)   { create(:lot, product: seller1_product) }

  let!(:seller2)               { create(:organization, :seller) }
  let!(:seller2_product)       { create(:product, organization: seller2) }
  let!(:seller2_product_price) { create(:price, product: seller2_product, sale_price: 2.00) }
  let!(:seller2_product_lot)   { create(:lot, product: seller2_product) }

  let(:discount) { create(:discount, code: "10percent", type: "percentage", payer: "market", discount: 10) }

  let!(:order_item1) { create(:order_item, product: seller1_product, quantity: 10, unit_price: 2.00) }
  let!(:order_item2) { create(:order_item, product: seller2_product, quantity: 20, unit_price: 2.00) }
  let!(:order)       { create(:order, items: [order_item1, order_item2], discount: discount) }

  let!(:cart_item1) { create(:cart_item, product: seller1_product, quantity: 10) }
  let!(:cart_item2) { create(:cart_item, product: seller2_product, quantity: 20) }
  let!(:cart)     { create(:cart, discount: discount, items: [cart_item1, cart_item2]) }

  context "apply to all items" do
    it "applies the discount over all the items" do
      ApplyDiscountToOrderItems.perform(cart: cart, order: order)

      expect(order.items.map(&:discount)).to include(2.0, 4.0)
    end
  end

  context "apply to seller items" do
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, seller_organization_id: seller1.id) }

    it "applies the discount to seller items only" do
      ApplyDiscountToOrderItems.perform(cart: cart, order: order)

      expect(order.items.map(&:discount)).to include(0.0, 2.0)
    end
  end
end
