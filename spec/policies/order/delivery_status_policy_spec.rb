require 'spec_helper'

describe Order::DeliveryStatusPolicy do

  let(:market_org)     { create(:organization, :market) }
  let!(:market)        { create(:market, organization: market_org) }
  let(:market_manager) { create(:user, :market_manager, managed_markets: [market], organizations: [market_org]) }

  let(:supplier)       { create(:user, :supplier) }
  let(:buyer)          { create(:user, :buyer) }

  let(:order)          { create(:order, :with_items, market: market) }

  let(:delivery_status_policy) { Order::DeliveryStatusPolicy.new(user, order) }

  before do
    allow(order).to receive(:undelivered_for_user?).with(user) { undelivered }
  end

  permissions :mark_delivered? do
    context 'as a market manager' do
      let(:user) { market_manager }

      context 'when order is not yet delivered' do
        let(:undelivered) { true }

        it 'returns true if order not direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { false }
          expect(delivery_status_policy.mark_delivered?).to be true
        end

        it 'returns true if order is direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { true }
          expect(delivery_status_policy.mark_delivered?).to be true
        end
      end

      context 'when order is delivered' do
        let(:undelivered) { false }

        it 'returns false' do
          expect(delivery_status_policy.mark_delivered?).to be false
        end
      end
    end

    context 'as a supplier' do
      let(:user) { supplier }

      context 'when order is undelivered' do
        let(:undelivered) { true }

        it 'returns false if order not direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { false }
          expect(delivery_status_policy.mark_delivered?).to be false
        end

        it 'returns true if order is direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { true }
          expect(delivery_status_policy.mark_delivered?).to be true
        end
      end

      context 'when order is delivered' do
        let(:undelivered) { false }

        it 'returns false' do
          expect(delivery_status_policy.mark_delivered?).to be false
        end
      end
    end

    context 'as a buyer' do
      let(:user) { buyer }
      let(:undelivered) { true }

      it 'returns false' do
        expect(delivery_status_policy.mark_delivered?).to be false
      end
    end
  end

  permissions :mark_undelivered? do
    context 'as a market manager' do
      let(:user) { market_manager }

      context 'when order is not yet delivered' do
        let(:undelivered) { true }

        it 'returns false' do
          expect(delivery_status_policy.mark_undelivered?).to be false
        end
      end

      context 'when order is delivered' do
        let(:undelivered) { false }

        it 'returns true' do
          expect(delivery_status_policy.mark_undelivered?).to be true
        end
      end
    end

    context 'as a supplier' do
      let(:user) { supplier }
      let(:undelivered) { true }

      it 'returns false' do
        expect(delivery_status_policy.mark_undelivered?).to be false
      end
    end

    context 'as a buyer' do
      let(:user) { buyer }
      let(:undelivered) { true }

      it 'returns false' do
        expect(delivery_status_policy.mark_undelivered?).to be false
      end
    end
  end
end