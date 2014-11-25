describe UserDeliveryContext do

  describe ".build(user:,delivery:)" do
    include_context "the mini market"

    let(:delivery) {create(:delivery, 
                           delivery_schedule: mm_delivery_schedule, 
                           orders: [ mm_order ])}

    it "correctly sets is_admin" do
      c = UserDeliveryContext.build(user: barry, delivery: delivery)
      expect(c.is_admin).to eq false
      c = UserDeliveryContext.build(user: aaron, delivery: delivery)
      expect(c.is_admin).to eq true
    end

    it "correctly sets is_market_manager" do
      c = UserDeliveryContext.build(user: barry, delivery: delivery)
      expect(c.is_market_manager).to eq false
      c = UserDeliveryContext.build(user: mary, delivery: delivery)
      expect(c.is_market_manager).to eq true
    end

    it "correctly sets is_seller" do
      c = UserDeliveryContext.build(user: barry, delivery: delivery)
      expect(c.is_seller).to eq false
      c = UserDeliveryContext.build(user: mary, delivery: delivery)
      expect(c.is_seller).to eq false
      c = UserDeliveryContext.build(user: sally, delivery: delivery)
      expect(c.is_seller).to eq true
    end
    
    it "correctly sets is_buyer_only" do
      c = UserDeliveryContext.build(user: mary, delivery: delivery)
      expect(c.is_buyer_only).to eq false
      c = UserDeliveryContext.build(user: sally, delivery: delivery)
      expect(c.is_buyer_only).to eq false
      c = UserDeliveryContext.build(user: barry, delivery: delivery)
      expect(c.is_buyer_only).to eq true
    end

    it "correctly sets packing_labels_feature" do
      mini_market_plan.update(packing_labels: false)
      c = UserDeliveryContext.build(user: mary, delivery: delivery)
      expect(c.packing_labels_feature).to eq false

      mini_market_plan.update(packing_labels: true)
      c = UserDeliveryContext.build(user: mary, delivery: delivery)
      expect(c.packing_labels_feature).to eq true
    end

    
  end
end
