describe UserOrderItemContext do
  describe ".build(user:,order_item:)" do
    include_context "the mini market"

    it "correctly sets is_admin" do
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.is_admin).to eq false
      c = UserOrderItemContext.build(user:aaron, order_item:mm_order1_item1)
      expect(c.is_admin).to eq true
    end

    it "correctly sets is_market_manager" do
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.is_market_manager).to eq false
      c = UserOrderItemContext.build(user:mary, order_item:mm_order1_item1)
      expect(c.is_market_manager).to eq true
    end

    it "correctly sets is_seller" do
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.is_seller).to eq true
      c = UserOrderItemContext.build(user:mary, order_item:mm_order1_item1)
      expect(c.is_seller).to eq false
    end

    it "correctly sets the feature availability" do
      mini_market_plan.update(sellers_edit_orders: true)
      mini_market.update(sellers_edit_orders: true)
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.sellers_edit_orders_feature).to eq true

      mini_market_plan.update(sellers_edit_orders: false)
      mini_market.update(sellers_edit_orders: true)
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.sellers_edit_orders_feature).to eq false

      mini_market_plan.update(sellers_edit_orders: true)
      mini_market.update(sellers_edit_orders: false)
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.sellers_edit_orders_feature).to eq false

      mini_market_plan.update(sellers_edit_orders: false)
      mini_market.update(sellers_edit_orders: false)
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.sellers_edit_orders_feature).to eq false
    end

    it "correctly sets the delivery_pending flag" do
      mm_order1_item1.delivery_status = 'pending'
      mm_order1_item1.save
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.delivery_pending).to eq true

      mm_order1_item1.delivery_status = 'foo'
      mm_order1_item1.save
      c = UserOrderItemContext.build(user:sally, order_item:mm_order1_item1)
      expect(c.delivery_pending).to eq false
    end
  end
end
