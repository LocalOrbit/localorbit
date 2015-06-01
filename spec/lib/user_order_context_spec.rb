require 'spec_helper'

describe UserOrderContext do
  describe ".build(user:,order_item:)" do
    include_context "the mini market"

    it "correctly sets is_admin" do
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.is_admin).to eq false
      c = UserOrderContext.build(user:aaron, order:mm_order)
      expect(c.is_admin).to eq true
    end

    it "correctly sets is_market_manager" do
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.is_market_manager).to eq false
      c = UserOrderContext.build(user:mary, order:mm_order)
      expect(c.is_market_manager).to eq true
    end

    it "correctly sets is_seller" do
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.is_seller).to eq true
      c = UserOrderContext.build(user:mary, order:mm_order)
      expect(c.is_seller).to eq false
    end

    it "correctly sets the seller_organization field" do
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.seller_organization).to eq seller_organization

      c = UserOrderContext.build(user:mary, order:mm_order)
      expect(c.seller_organization).to eq nil

      c = UserOrderContext.build(user:barry, order:mm_order)
      expect(c.seller_organization).to eq nil
    end

    it "correctly sets the feature availability" do
      mini_market_plan.update(sellers_edit_orders: true)
      mini_market.update(sellers_edit_orders: true)
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.sellers_edit_orders_feature).to eq true

      mini_market_plan.update(sellers_edit_orders: false)
      mini_market.update(sellers_edit_orders: true)
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.sellers_edit_orders_feature).to eq false

      mini_market_plan.update(sellers_edit_orders: true)
      mini_market.update(sellers_edit_orders: false)
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.sellers_edit_orders_feature).to eq false

      mini_market_plan.update(sellers_edit_orders: false)
      mini_market.update(sellers_edit_orders: false)
      c = UserOrderContext.build(user:sally, order:mm_order)
      expect(c.sellers_edit_orders_feature).to eq false
    end

  end
end
