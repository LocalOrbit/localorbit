require 'spec_helper'

describe PaymentProvider::Handlers::TransferPaid do
  subject { described_class }

  describe '.extract_job_params' do
    it 'extracts the account and transfer ids' do
      event = double(user_id: 'account id')
      transfer = double(id: 'transfer id', amount: 'the pennies')
      allow(event).to receive_message_chain('data.object') { transfer }
      expect(subject.extract_job_params(event)).
        to eq(transfer_id: 'transfer id', stripe_account_id: 'account id', amount_in_cents: 'the pennies')
    end
  end

  describe '.handle' do
    let!(:user) { create(:user) }
    let!(:market) { create(:market, stripe_account_id: 'account id', managers: [user]) }
    let!(:market2) { create(:market) }

    it 'does nothing if no stripe_account_id is given' do
      expect(PaymentProvider::Stripe).to_not receive(:create_market_payment)
      expect(PaymentMailer).to_not receive(:payment_received)
      subject.handle(transfer_id: 'transfer id', stripe_account_id: nil, amount_in_cents: '1234')
      expect(Payment.count).to eq(0)
    end

    context 'when there is no Market connected with the given stripe_account_id' do
      it 'does nothing if no Market bears the given stripe_account_id' do
        market.update(stripe_account_id: 'will not match')
        expect(PaymentProvider::Stripe).to_not receive(:create_market_payment)
        expect(PaymentMailer).to_not receive(:payment_received)
        subject.handle(transfer_id: 'transfer id', stripe_account_id: 'account id', amount_in_cents: '1234')
        expect(Payment.count).to eq(0)
      end
    end

    it 'creates a market payment for the transfer amount and releated orders' do
      payment = double('the payment', id: 187, payee: market)
      expect(PaymentProvider::Stripe).to receive(:order_ids_for_market_payout_transfer).
        with(transfer_id: 'transfer id', stripe_account_id: 'account id').
        and_return(['123', '456'])
      expect(PaymentProvider::Stripe).to receive(:create_market_payment).
        with(transfer_id: 'transfer id', market: market, order_ids: ['123', '456'], 
             status:'paid', amount: '12.34'.to_d).
        and_return(payment)

      expect(Financials::PaymentNotifier).to receive(:market_payment_received).with(
        payment: payment,
        async: false
      )
      subject.handle(transfer_id: 'transfer id', stripe_account_id: 'account id', 
                     amount_in_cents: '1234')
    end

  end
end
