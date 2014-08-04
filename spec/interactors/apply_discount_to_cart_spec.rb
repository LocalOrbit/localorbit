require 'spec_helper'

describe ApplyDiscountToCart do
  let!(:market1)               { create(:market) }

  let!(:buyer)                 { create(:organization, :buyer, markets: [market1]) }

  let!(:seller1)               { create(:organization, :seller, markets: [market1]) }
  let!(:seller1_product)       { create(:product, organization: seller1) }
  let!(:seller1_product_price) { create(:price, product: seller1_product, sale_price: 2.00) }
  let!(:seller1_product_lot)   { create(:lot, product: seller1_product)}

  let!(:seller2)               { create(:organization, :seller, markets: [market1]) }
  let!(:seller2_product)       { create(:product, organization: seller2) }
  let!(:seller2_product_price) { create(:price, product: seller2_product, sale_price: 2.00) }
  let!(:seller2_product_lot)   { create(:lot, product: seller2_product)}

  let(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10)}

  let!(:cart_item1) { create(:cart_item, product: seller1_product, quantity: 10) }
  let!(:cart_item2) { create(:cart_item, product: seller2_product, quantity: 20) }
  let!(:cart)     { create(:cart, market: market1, organization: buyer, discount: discount, items: [cart_item1, cart_item2])}

  it "allows a discount to be applied" do
    result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

    expect(result.context).to be_success
    expect(result.message).to eql("Discount applied")
  end

  context "order maximum" do
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, maximum_order_total: 50.00) }

    it "limits the discount to the maximum order total" do
      result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

      expect(result.context).to be_failure
      expect(result.message).to eql("Discount code requires a maximum of $50.00")
    end
  end

  context "order minimum" do
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, minimum_order_total: 100.00) }

    it "limits the discount to the maximum order total" do
      result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

      expect(result.context).to be_failure
      expect(result.message).to eql("Discount code requires a minimum of $100.00")
    end
  end

  context "market" do
    let!(:market2)  { create(:market) }
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, market: market2) }

    it "requires the buyer to be in a market" do
      result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

      expect(result.context).to be_failure
      expect(result.message).to eql("Invalid discount code")
    end
  end

  context "buyer" do
    let!(:buyer2)  { create(:organization) }
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, buyer_organization_id: buyer2.id) }

    it "requires a particular buyer" do
      result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

      expect(result.context).to be_failure
      expect(result.message).to eql("Invalid discount code")
    end
  end

  context "maximum uses" do
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, maximum_uses: 2) }
    let!(:order1) { create(:order, discount: discount)}
    let!(:order2) { create(:order, discount: discount)}

    it "requires a particular buyer" do
      result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

      expect(result.context).to be_failure
      expect(result.message).to eql("Discount code expired")
    end
  end

  context "maximum organizational uses" do
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, maximum_organization_uses: 1) }
    let!(:order1) { create(:order, discount: discount, organization: buyer)}

    it "requires a particular buyer" do
      result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

      expect(result.context).to be_failure
      expect(result.message).to eql("Discount code expired")
    end
  end

  context "date range" do
    let!(:discount) { create(:discount, code: "10percent", type: "percentage", discount: 10, start_date: 3.days.ago, end_date: 1.hours.from_now) }
    let!(:order1) { create(:order, discount: discount, organization: buyer)}

    it "requires a particular buyer" do
      Timecop.travel(1.day.from_now) do
        result = ApplyDiscountToCart.perform(cart: cart, code: discount.code)

        expect(result.context).to be_failure
        expect(result.message).to eql("Discount code expired")
      end
    end
  end
end
