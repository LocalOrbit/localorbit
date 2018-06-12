require 'spec_helper'

describe Order::DeliveryStatusPolicy do

  let(:market_org)     { create(:organization, :market) }
  let!(:market)        { create(:market, organization: market_org) }
  let(:market_manager) { create(:user, :market_manager, managed_markets: [market], organizations: [market_org]) }

  let(:supplier)       { create(:user, :supplier) }
  let(:buyer)          { create(:user, :buyer) }

  let(:order)          { create(:order, :with_items, market: market) }

  before do
    allow(order).to receive(:undelivered_for_user?).with(user) { undelivered }
  end

  permissions :mark_delivered? do
    context 'as a market manager' do
      let(:user) { market_manager }

      context 'when order is not yet delivered' do
        let(:undelivered) { true }

        it 'grants access if order is not direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { false }
          expect(described_class).to permit(user, order)
        end

        it 'grants access if order is direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { true }
          expect(described_class).to permit(user, order)
        end
      end

      context 'when order is delivered' do
        let(:undelivered) { false }

        it 'denies access' do
          expect(described_class).to_not permit(user, order)
        end
      end
    end

    context 'as a supplier' do
      let(:user) { supplier }

      context 'when order is undelivered' do
        let(:undelivered) { true }

        it 'denies access if order is not direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { false }
          expect(described_class).to_not permit(user, order)
        end

        it 'grants access if order is direct delivery' do
          allow(order).to receive_message_chain('delivery.delivery_schedule.direct_to_customer?') { true }
          expect(described_class).to permit(user, order)
        end
      end

      context 'when order is delivered' do
        let(:undelivered) { false }

        it 'denies access' do
          expect(described_class).to_not permit(user, order)
        end
      end
    end

    context 'as a buyer' do
      let(:user) { buyer }
      let(:undelivered) { true }

      it 'denies access' do
        expect(described_class).to_not permit(user, order)
      end
    end
  end

  permissions :mark_undelivered? do
    context 'as a market manager' do
      let(:user) { market_manager }

      context 'when order is not yet delivered' do
        let(:undelivered) { true }

        it 'denies access' do
          expect(described_class).to_not permit(user, order)
        end
      end

      context 'when order is delivered' do
        let(:undelivered) { false }

        it 'grants access' do
          expect(described_class).to permit(user, order)
        end
      end
    end

    context 'as a supplier' do
      let(:user) { supplier }
      let(:undelivered) { true }

      it 'denies access' do
        expect(described_class).to_not permit(user, order)
      end
    end

    context 'as a buyer' do
      let(:user) { buyer }
      let(:undelivered) { true }

      it 'denies access' do
        expect(described_class).to_not permit(user, order)
      end
    end
  end
end