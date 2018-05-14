require 'spec_helper'

RSpec.describe MergeOrder do

  describe '.perform' do
    context 'with empty args' do
      let(:perform) { described_class.perform }

      it 'raises an error' do
        expect { perform }.to raise_error RuntimeError
      end
    end

    context 'with orig_order and dest_order the same' do
      let(:user) { build_stubbed(:user) }
      let(:organization) { build_stubbed(:organization) }
      let(:orig_order) { build_stubbed(:order, organization: organization) }
      let(:dest_order) { orig_order }
      let(:perform) { described_class.perform(user: user, orig_order: orig_order,
        dest_order: dest_order) }

      it 'fails with message ‘Origin and Destination orders must be different’' do
        expect(perform.success?).to be false
        expect(perform.message).to match(/Origin and Destination orders must be different/)
      end
    end

    context 'with orders from different organizations' do
      let(:user) { build_stubbed(:user) }
      let(:orig_order) { build_stubbed(:order) }
      let(:dest_order) { build_stubbed(:order) }
      let(:perform) { described_class.perform(user: user, orig_order: orig_order,
        dest_order: dest_order) }

      it 'fails with message ‘Origin and Destination must have the same buyer’' do
        expect(perform.success?).to be false
        expect(perform.message).to match(/Origin and Destination must have the same buyer/)
      end
    end

    context 'when dest_order is delivered' do
      let(:user) { build_stubbed(:user) }
      let(:organization) { build_stubbed(:organization) }
      let(:orig_order) { build_stubbed(:order, organization: organization) }
      let(:dest_order) { build_stubbed(:order, :delivered, organization: organization) }
      let(:perform) { described_class.perform(user: user, orig_order: orig_order,
        dest_order: dest_order) }

      it 'fails with message ‘Destination Order must be Undelivered’' do
        expect(perform.success?).to be false
        expect(perform.message).to match(/Destination Order must be Undelivered/)
      end
    end

    context 'when orig_order and dest_order have different payment methods' do
      let(:user) { build_stubbed(:user) }
      let(:organization) { build_stubbed(:organization) }
      let(:orig_order) { build_stubbed(:order, organization: organization, payment_method: 'check') }
      let(:dest_order) { build_stubbed(:order, :delivered, organization: organization, payment_method: 'credit card') }
      let(:perform) { described_class.perform(user: user, orig_order: orig_order,
        dest_order: dest_order) }

      it 'fails with message ‘Origin and Destination orders must have same payment method’' do
        expect(perform.success?).to be false
        expect(perform.message).to match(/Origin and Destination orders must have same payment method/)
      end
    end

    context 'with valid arguments' do
      let(:user) { create(:user) }
      let(:organization) { create(:organization) }
      let(:product1) { create(:product, :sellable, name: 'Delicious') }
      let(:product2) { create(:product, :sellable, name: 'Spartan') }
      let(:orig_order_item1) { create(:order_item, product: product1) }
      let(:orig_order_item2) { create(:order_item, product: product2) }
      let(:dest_order_item1) { create(:order_item, product: product1) }
      let(:orig_order) { create(:order, organization: organization) }
      let(:dest_order) { create(:order, organization: organization) }
      let(:perform) { described_class.perform(user: user, orig_order: orig_order,
        dest_order: dest_order) }

      before do
        # allow(orig_order).to receive(:'save!').and_return(true)
        # allow(dest_order).to receive(:'save!').and_return(true)
        orig_order.items << [orig_order_item1, orig_order_item2]
        dest_order.items << [dest_order_item1]
        StoreOrderFees.perform(payment_provider: orig_order.payment_provider, order: orig_order)
      end

      it 'succeeds' do
        expect(perform.success?).to be true
      end

      it 'when orig and dest have the same order item it adds the order item quantities together' do
        perform
        expect(dest_order.reload.items.first.quantity).to eq BigDecimal('2.0')
      end

      it 'when orig_order has distinct order_item add it to dest_order order_items' do
        perform
        expect(dest_order.reload.items.last.product.name).to eq product2.name
      end

      it 'sets the quantity to zero for all orig_order order_items' do
        perform
        expect(orig_order.reload.items.map(&:quantity).all?(&:zero?)).to be true
      end

      it 'set the market_seller_fee to zero for all orig_order order_items' do
        perform
        expect(orig_order.reload.items.map(&:market_seller_fee).all?(&:zero?)).to be true
      end

      it 'calls RemoveCredit with the orig_order' do
        expect(RemoveCredit).to receive(:perform).with(hash_including(order: orig_order))
        perform
      end

      it 'calls update_total_cost and save! on the orig_order' do
        expect(orig_order).to receive(:update_total_cost)
        expect(orig_order).to receive(:'save!')
        perform
      end

      it 'calls update_total_cost and save! on the dest_order' do
        expect(dest_order).to receive(:update_total_cost)
        expect(dest_order).to receive(:'save!')
        perform
      end

      # meh, spec is vague
      it 'calls UpdatePurchase on both orig and dest orders' do
        expect(UpdatePurchase).to receive(:perform).twice
        perform
      end

      # more meh, vague specs on what is happening
      it 'creates two audit records' do
        expect(Audit).to receive(:'create!').twice.and_return(double.as_null_object)
        perform
      end
    end
  end
end
