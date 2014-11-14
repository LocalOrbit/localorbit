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

  require 'constructor_struct'
  UserDeliveryContext = ConstructorStruct.new(
    :available_features,
    :is_market_manager,
    :is_seller,
    :is_buyer,
    :is_admin
  )


  describe ".packing_labels?" do
    let(:user_delivery_context) { 
      UserDeliveryContext.new( 
        available_features: available_features,
        is_market_manager: is_market_manager,
        is_seller: is_market_seller,
        is_buyer_only: is_market_buyer_only,
        is_market_admin: is_market_admin
      ) 
    }

    let(:available_features) { [] }
    let(:is_market_manager) { false }
    let(:is_seller) { false }
    let(:is_buyer_only) { false }
    let(:is_admin) { false }
    
    context "market with order_printables enabled in plan" do
      let(:available_features) { [ :packing_labels ] }

      context "market managers" do
        let(:is_market_manager) { true }

        it "returns true" do
          expect(subject.packing_labels?(user_delivery_context)).to eq true
        end
      end

      context "sellers" do
        let(:is_seller) { true }

        it "returns true" do
          expect(subject.packing_labels?(user_delivery_context)).to eq true
        end
      end

      context "admins" do
        let(:is_admin) { true }

        it "returns true" do
          expect(subject.packing_labels?(user_delivery_context)).to eq true
        end
      end

      context "buyers" do
        let(:is_buyer_only) { true }

        it "returns false" do
          expect(subject.packing_labels?(user_delivery_context)).to eq false
        end
      end
    end

    context "market with order_printables DISabled in plan" do
      it "returns false for everyone" do
        raise "TODO"
      end
    end

  end

end
