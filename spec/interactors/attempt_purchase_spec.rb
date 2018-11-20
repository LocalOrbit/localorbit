require 'spec_helper'

describe AttemptPurchase do
  context 'making a purchase through Stripe' do
    include_context 'the mini market'

    let(:cart) {
      create(:cart,
             organization: buyer_organization,
             market: mini_market)
    }
    let(:order) { mm_order1 } # from mini market
    let(:payment_method) { 'credit card' }
    let(:amount) { '100.00'.to_d }
    let(:order_params) {
      HashWithIndifferentAccess.new(
        payment_method: payment_method,
        credit_card: { id: 'd34db33f' }
      )
    }
    let(:params) {
      {
        payment_provider: PaymentProvider::Stripe.id,
        cart: cart,
        order: order,
        order_params: order_params
      }
    }

    context 'valid credit card order' do
      let(:stripe_charge) { double(id: 'fake_stripe_id', application_fee: '2', metadata: {}, save: true) }
      let(:bank_account) { instance_double(BankAccount) }
      let(:payment) { instance_double(Payment, id: 1, persisted?: true) }

      before do
        #
        # This could be a nasty shortcut, since Cart#total is a summation method
        # involving a bunch of CartItems and price schemes we don't have setup in
        # this test.  HOWEVER, it's very questionable that Cart should even be
        # USED by AttemptPurchase, since by the time AttemptPurchase is invoked,
        # CreateOrder has already transmuted all Cart data into an Order.
        # Consider dropping Cart usage altogether withing the AttemptPurchase
        # interactor. For now, let's just hotwire #total and move on.
        #      -- crosby 5/7/2015
        #
        allow(cart).to receive(:total).and_return(order.gross_total)

        allow(PaymentProvider).to receive(:charge_for_order).and_return(stripe_charge)
        allow(PaymentProvider).to receive(:translate_status).and_return('paid')
        allow(PaymentProvider).to receive(:create_order_payment).and_return(payment)
        allow(PaymentProvider).to receive(:store_payment_fees)
        allow(buyer_organization).to receive_message_chain(:bank_accounts, :find).and_return(bank_account)
      end

      it 'creates charge via PaymentProvider' do
        expect(PaymentProvider).to receive(:charge_for_order)
        described_class.perform(params)
      end

      it 'creates order payment via PaymentProvider' do
        expect(PaymentProvider).to receive(:create_order_payment)
        described_class.perform(params)
      end

      it 'adds metadata to the charge at Stripe' do
        expect(stripe_charge.metadata).to receive('[]=').exactly(3).times
        expect(stripe_charge).to receive(:save)
        described_class.perform(params)
      end

      it 'marks the order as paid' do
        expect(order).to receive(:update).with(payment_method: 'credit card', payment_status: 'paid')
        described_class.perform(params)
      end

      it 'marks all the order items as paid' do
        allow(order).to receive(:update)
        expect(order).to receive_message_chain(:items, :update_all).with(payment_status: 'paid')
        described_class.perform(params)
      end

      it 'stores payment fees via PaymentProvider' do
        expect(PaymentProvider).to receive(:store_payment_fees)
        described_class.perform(params)
      end

      it 'result shows success' do
        result = described_class.perform(params)
        expect(result.success?).to be true
      end

      it 'adds payment to context' do
        result = described_class.perform(params)
        expect(result.context[:payment]).to be
      end
    end

    context 'non-CC order' do
      let(:payment_method) { 'purchase_order'}

      it 'does nothing' do
        expect(PaymentProvider).not_to receive(:charge_for_order)
        expect(PaymentProvider).not_to receive(:translate_status)
        expect(PaymentProvider).not_to receive(:create_order_payment)
        result = described_class.perform(params)
        expect(result.success?).to be true
      end
    end

    context 'no order' do
      let(:order) { nil }

      it 'does nothing' do
        expect(PaymentProvider).not_to receive(:charge_for_order)
        expect(PaymentProvider).not_to receive(:translate_status)
        expect(PaymentProvider).not_to receive(:create_order_payment)
        result = described_class.perform(params)
        expect(result.success?).to be true
      end
    end
  end
end
