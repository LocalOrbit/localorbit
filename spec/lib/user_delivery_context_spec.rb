describe UserDeliveryContext do

  describe ".build_delivery_context(user:,delivery:)" do
    let(:plan)                   { create(:plan, :grow) }
    let!(:market)                { create(:market, :with_delivery_schedule, :with_address, plan: plan) }
    let!(:wrong_market)          { create(:market, :with_delivery_schedule, :with_address, plan: plan) }
    let!(:buyer)                 { create(:organization, :buyer, markets: [market]) }
    let!(:wrong_organization)    { create(:organization, :buyer, markets: [market]) }
    let(:order)                  { create :order, :with_items, organization: buyer, market: market }

    let(:user)                   { create(:user, organizations: [buyer]) }
    let(:delivery) {create(:delivery, delivery_schedule: market.delivery_schedules.first, orders: [order])}

    it "creates a user delivery context from a user and delivery" do
      delivery_context = UserDeliveryContext.build_delivery_context(user: user, delivery: delivery)
      full_list_of_features = [:discount_codes,
        :cross_selling,
        :custom_branding,
        :automatic_payments,
        :advanced_pricing,
        :advanced_inventory,
        :promotions,
        :order_printables,
        :packing_labels
      ]
      expect(delivery_context.available_features).to contain_exactly(*full_list_of_features)
      expect(delivery_context.is_market_manager).to eq false
      expect(delivery_context.is_seller).to eq false
      expect(delivery_context.is_buyer_only).to eq true
      expect(delivery_context.is_admin).to eq false
      full_list_of_features.each do |feature|
        expect(delivery_context.has_feature(feature)).to eq true
      end
    end
  end
end
