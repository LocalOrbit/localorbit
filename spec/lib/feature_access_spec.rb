require "spec_helper"

describe FeatureAccess do
  subject { described_class }
  let(:plan)                   { create(:plan, :grow) }
  let!(:market_org)            { create(:organization, :market, plan: plan)}
  let!(:market)                { create(:market, :with_delivery_schedule, :with_address, organization: market_org) }
  let!(:wrong_market_org)      { create(:organization, :market, plan: plan)}
  let!(:wrong_market)          { create(:market, :with_delivery_schedule, :with_address, organization: wrong_market_org) }
  let!(:buyer)                 { create(:organization, :buyer, markets: [market]) }
  let!(:wrong_organization)    { create(:organization, :buyer, markets: [market]) }
  let(:order)                  { create :order, :with_items, organization: buyer, market: market }
  let(:user)                   { create(:user, :buyer, organizations: [buyer]) }
  let(:admin)                  { create(:user, :admin) }
  let(:market_manager)         { create(:user, :market_manager, managed_markets: [market]) }
  let(:localeyes_plan)         { create(:plan, :localeyes) }
  let(:localeyes_market_org)   { create(:organization, :market, plan: localeyes_plan)}
  let(:localeyes_market)       { create(:market, :with_delivery_schedule, :with_address, organization: localeyes_market_org) }

  before do
    user.markets << market
  end

  describe ".order_templates?" do
    it "only returns true if the market belongs to the localeyes plan" do
      expect(FeatureAccess.order_templates?(market: market)).to eq false
      expect(FeatureAccess.order_templates?(market: localeyes_market)).to eq true
    end
  end

  describe ".order_printables?" do
    it "returns false if the user does not belong to the order's market" do
      order.market = wrong_market
      order.save
      expect(subject.order_printables?(user: user, order: order)).to eq false
    end

    it "returns false for start up markets" do
      plan = create(:plan, :start_up)
      market.organization.plan = plan
      market.save
      expect(FeatureAccess.order_printables?(user: user, order: order)).to eq false
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
      user = create(:user, :admin)
      market.organization.plan = plan
      market.organization.org_type = "A"
      market.save
      expect(subject.order_printables?(user: user, order: order)).to eq true
    end
  end


  context "Delivery tools perms" do
    let(:user_delivery_context) {
      UserDeliveryContext.new(
        packing_labels_feature: packing_labels_feature,
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        is_buyer_only: is_buyer_only,
        is_admin: is_admin
      )
    }

    let(:packing_labels_feature) { false }
    let(:is_market_manager) { false }
    let(:is_seller) { false }
    let(:is_buyer_only) { false }
    let(:is_admin) { false }

    describe ".packing_labels?" do

      context "market with packing_labels enabled in plan" do
        let(:packing_labels_feature) { true }

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


      context "market without packing labels enabled in plan" do
        let(:packing_labels_feature) { false }

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

    describe ".master_packing_slips?" do
      context "admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.master_packing_slips?(user_delivery_context: user_delivery_context)).to eq true
        end
      end
      context "market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.master_packing_slips?(user_delivery_context: user_delivery_context)).to eq true
        end
      end
      context "sellers" do
        let(:is_seller) { true }
        it "returns false" do
          expect(subject.master_packing_slips?(user_delivery_context: user_delivery_context)).to eq false
        end
      end
      context "buyers" do
        let(:is_buyer_only) { true }
        it "returns false" do
          expect(subject.master_packing_slips?(user_delivery_context: user_delivery_context)).to eq false
        end
      end
    end

  end

  describe ".edit_ordered_quantity?" do
    let(:context) {
      UserOrderItemContext.new(
        delivery_pending: delivery_pending,
        is_admin: is_admin,
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        sellers_edit_orders_feature: sellers_edit_orders_feature
      )
    }

    let(:delivery_pending) {false}
    let(:is_admin) {false}
    let(:is_market_manager) { false }
    let(:is_seller) {false}
    let(:sellers_edit_orders_feature) {false}

    context "delivery_pending false" do
      it "returns false" do
        expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns false" do
          expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq false
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns false" do
          expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq false
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq false
          end
        end

        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns false" do
            expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq false
          end
        end
      end
    end

    context "delivery_pending true" do
      let(:delivery_pending) { true }

      it "returns false with no other interesting conditions met" do
        expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq false
          end
        end

        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns true" do
            expect(subject.edit_ordered_quantity?(user_order_item_context: context)).to eq true
          end
        end
      end

    end
  end

  describe ".edit_delivered_quantity?" do
    let(:context) {
      UserOrderItemContext.new(
        delivery_pending: delivery_pending,
        is_admin: is_admin,
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        sellers_edit_orders_feature: sellers_edit_orders_feature
      )
    }

    let(:delivery_pending) {false}
    let(:is_admin) {false}
    let(:is_market_manager) { false }
    let(:is_seller) {false}
    let(:sellers_edit_orders_feature) {false}

    context "delivery_pending false" do
      it "returns false with no other interesting criteria set true" do
        expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq false
          end
        end

        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) {true}
          it "returns true" do
            expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq true
          end
        end
      end
    end

    context "delivery_pending true" do
      let(:delivery_pending) { true }

      it "returns false with no other interesting conditions met" do
        expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq false
          end
        end
        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns true" do
            expect(subject.edit_delivered_quantity?(user_order_item_context: context)).to eq true
          end
        end
      end

    end

  end

  describe ".delete_order_item?" do
    let(:context) {
      UserOrderItemContext.new(
        delivery_pending: delivery_pending,
        is_admin: is_admin,
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        sellers_edit_orders_feature: sellers_edit_orders_feature
      )
    }

    let(:delivery_pending) {false}
    let(:is_admin) {false}
    let(:is_market_manager) { false }
    let(:is_seller) {false}
    let(:sellers_edit_orders_feature) {false}

    context "delivery_pending false" do
      it "returns false" do
        expect(subject.delete_order_item?(user_order_item_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns false" do
          expect(subject.delete_order_item?(user_order_item_context: context)).to eq false
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns false" do
          expect(subject.delete_order_item?(user_order_item_context: context)).to eq false
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.delete_order_item?(user_order_item_context: context)).to eq false
          end
        end

        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns false" do
            expect(subject.delete_order_item?(user_order_item_context: context)).to eq false
          end
        end
      end
    end

    context "delivery_pending true" do
      let(:delivery_pending) { true }

      it "returns false with no other interesting conditions met" do
        expect(subject.delete_order_item?(user_order_item_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.delete_order_item?(user_order_item_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.delete_order_item?(user_order_item_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.delete_order_item?(user_order_item_context: context)).to eq false
          end
        end

        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns true" do
            expect(subject.delete_order_item?(user_order_item_context: context)).to eq true
          end
        end
      end

    end
  end

  describe ".order_action_links?" do
    let(:context) {
      UserOrderContext.new(
        is_admin: is_admin,
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        sellers_edit_orders_feature: sellers_edit_orders_feature
      )
    }

    let(:delivery_pending) {false}
    let(:is_admin) {false}
    let(:is_market_manager) { false }
    let(:is_seller) {false}
    let(:sellers_edit_orders_feature) { false }

    context "delivery_pending false" do
      it "returns false with no other interesting criteria set true" do
        expect(subject.order_action_links?(user_order_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.order_action_links?(user_order_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.order_action_links?(user_order_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.order_action_links?(user_order_context: context)).to eq false
          end
        end

        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns true" do
            expect(subject.order_action_links?(user_order_context: context)).to eq true
          end
        end
      end
    end

    context "delivery_pending true" do
      let(:delivery_pending) { true }

      it "returns false with no other interesting conditions met" do
        expect(subject.order_action_links?(user_order_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.order_action_links?(user_order_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.order_action_links?(user_order_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.order_action_links?(user_order_context: context)).to eq false
          end
        end
        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns true" do
            expect(subject.order_action_links?(user_order_context: context)).to eq true
          end
        end
      end

    end

  end

  describe ".add_order_items?" do
    let(:context) {
      UserOrderContext.new(
        is_admin: is_admin,
        is_market_manager: is_market_manager,
        is_seller: is_seller,
        sellers_edit_orders_feature: sellers_edit_orders_feature
      )
    }

    let(:delivery_pending) {false}
    let(:is_admin) {false}
    let(:is_market_manager) { false }
    let(:is_seller) {false}
    let(:sellers_edit_orders_feature) { false }

    context "delivery_pending false" do
      it "returns false with no other interesting criteria set true" do
        expect(subject.add_order_items?(user_order_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.add_order_items?(user_order_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.add_order_items?(user_order_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.add_order_items?(user_order_context: context)).to eq false
          end
        end

        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns true" do
            expect(subject.add_order_items?(user_order_context: context)).to eq true
          end
        end
      end
    end

    context "delivery_pending true" do
      let(:delivery_pending) { true }

      it "returns false with no other interesting conditions met" do
        expect(subject.add_order_items?(user_order_context: context)).to eq false
      end

      context "for admins" do
        let(:is_admin) { true }
        it "returns true" do
          expect(subject.add_order_items?(user_order_context: context)).to eq true
        end
      end

      context "for market managers" do
        let(:is_market_manager) { true }
        it "returns true" do
          expect(subject.add_order_items?(user_order_context: context)).to eq true
        end
      end

      context "for sellers" do
        let(:is_seller) { true }
        context "when sellers_edit_orders feature is NOT available in this market" do
          it "returns false" do
            expect(subject.add_order_items?(user_order_context: context)).to eq false
          end
        end
        context "when sellers_edit_orders feature is available in this market" do
          let(:sellers_edit_orders_feature) { true }
          it "returns true" do
            expect(subject.add_order_items?(user_order_context: context)).to eq true
          end
        end
      end

    end
  end

  describe ".sellers_edit_orders_feature_available?" do
    context "Market has no Plan" do
      before do
        market_org.update_column :plan_id, nil
      end
      it "returns false" do
        expect(subject.sellers_edit_orders_feature_available?(market: market)).to eq nil
      end
    end

    context "Market Plan has :sellers_edit_orders set true" do
      before do
        plan.update sellers_edit_orders: true
      end
      it "returns true" do
        expect(subject.sellers_edit_orders_feature_available?(market: market)).to eq true
      end
    end

    context "Market Plan has :sellers_edit_orders set false" do
      before do
        plan.update sellers_edit_orders: false
      end
      it "returns false" do
        expect(subject.sellers_edit_orders_feature_available?(market: market)).to eq false
      end
    end

  end

  describe ".has_procurement_managers?" do
    context "Market has no Plan" do
      before do
        market.update_column :plan_id, nil
      end
      it "returns false" do
        expect(subject.has_procurement_managers?(market: market)).to eq false
      end
    end

    context "Grow Plan" do
      it "returns false" do
        expect(subject.has_procurement_managers?(market: market)).to eq false
      end
    end

    context "LocalEyes Plan" do
      it "returns true" do
        expect(subject.has_procurement_managers?(market: localeyes_market)).to eq true
      end
    end

  end
end
