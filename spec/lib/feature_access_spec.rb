require "spec_helper"

describe FeatureAccess do
  subject { described_class }
  let(:plan)                   { create(:plan, :grow) }
  let!(:market)                { create(:market, :with_delivery_schedule, :with_address, plan: plan) }
  let!(:wrong_market)          { create(:market, :with_delivery_schedule, :with_address, plan: plan) }
  let!(:buyer)                 { create(:organization, :buyer, markets: [market]) }
  let!(:wrong_organization)    { create(:organization, :buyer, markets: [market]) }
  let(:order)                  { create :order, :with_items, organization: buyer, market: market }
  let(:user)                   { create(:user, organizations: [buyer]) }

  before do
    user.markets << market
  end

  describe ".order_printables?" do
    it "returns false if the user does not belong to the order's market" do
      order.market = wrong_market
      order.save
      expect(subject.order_printables?(user: user, order: order)).to eq false
    end

    it "returns false for start up markets" do
      plan = create(:plan, :start_up)
      market.plan = plan
      market.save
      expect(subject.order_printables?(user: user, order: order)).to eq false
    end

    it "returns false for non market managers who did not place the order" do
      user.organizations = [wrong_organization]
      user.save
      expect(subject.order_printables?(user: user, order: order)).to eq false
    end

    it "returns true otherwise" do
      expect(subject.order_printables?(user: user, order: order)).to eq true
    end

    it "always returns true for admins" do
      plan = create(:plan, :start_up)
      market.plan = plan
      market.save
      user.role = "admin"
      user.save
      expect(subject.order_printables?(user: user, order: order)).to eq true
    end
  end

  UserDeliveryContext = ConstructorStruct.new(
      :available_features,
      :is_market_manager,
      :is_seller,
      :is_buyer_only,
      :is_admin
    ) do

    def has_feature(sym)
      available_features.include?(sym)
    end
  end

  describe ".build_delivery_context(user:,delivery:)" do
    let(:delivery) {create(:delivery, orders: [order])}

    it "creates a user delivery context from a user and delivery" do
      delivery_context = FeatureAccess.build_delivery_context(user: user, delivery: delivery)
      expect(delivery_context.available_features).to contain_exactly(:discount_codes, :cross_selling, :custom_branding, :automatic_payments, :advanced_pricing, :advanced_inventory, :promotions, :order_printables)
      expect(delivery_context.is_market_manager).to eq false
      expect(delivery_context.is_seller).to eq false
      expect(delivery_context.is_buyer_only).to eq true
      expect(delivery_context.is_admin).to eq false
      expect(delivery_context.has_feature(:order_printables)).to eq true
    end
  end


  describe ".packing_labels?" do
    let(:user_delivery_context) {
      UserDeliveryContext.new(
        available_features: available_features,
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        is_buyer_only: is_buyer_only,
        is_admin: is_admin
      )
    }

    let(:available_features) { [] }
    let(:is_market_manager) { false }
    let(:is_seller) { false }
    let(:is_buyer_only) { false }
    let(:is_admin) { false }

    context "market with order_printables enabled in plan" do
      let(:available_features) { [ :order_printables ] }

      context "market managers" do
        let(:is_market_manager) { true }

        it "returns true" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq true
        end
      end

      context "sellers" do
        let(:is_seller) { true }

        it "returns true" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq true
        end
      end

      context "admins" do
        let(:is_admin) { true }

        it "returns true" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq true
        end
      end

      context "buyers" do
        let(:is_buyer_only) { true }

        it "returns false" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq false
        end
      end
    end


    context "market with order_printables enabled in plan" do
      let(:available_features) { [ :other, :things ] }

      context "admins" do
        let(:is_admin) { true }

        it "returns true, because admins are admins" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq true
        end
      end

      context "market managers" do
        let(:is_market_manager) { true }

        it "returns false" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq false
        end
      end

      context "sellers" do
        let(:is_seller) { true }

        it "returns false" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq false
        end
      end

      context "buyers" do
        let(:is_buyer_only) { true }

        it "returns false" do
          expect(subject.packing_labels?(user_delivery_context: user_delivery_context)).to eq false
        end
      end
    end

  end

end
