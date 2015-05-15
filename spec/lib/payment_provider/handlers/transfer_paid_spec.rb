require 'spec_helper'

describe PaymentProvider::Handlers::TransferPaid do
  subject { described_class }

  context '#extract_job_params' do
    it 'extracts the account and transfer ids' do
      event = double(user_id: 'account id')
      transfer = double(id: 'transfer id', amount: 'the amount')
      allow(event).to receive_message_chain('data.object') { transfer }
      expect(subject.extract_job_params(event)).
        to eq(transfer_id: 'transfer id', stripe_account_id: 'account id', amount: 'the amount')
    end
  end

  context '#handle' do
    let!(:user) { create(:user) }
    let!(:market) { create(:market, stripe_account_id: 'account id', managers: [user]) }
    let!(:market2) { create(:market) }

    it 'does nothing if no stripe_account_id is given' do
      expect(PaymentProvider::Stripe).to_not receive(:create_market_payment)
      expect(PaymentMailer).to_not receive(:payment_received)
      subject.handle(transfer_id: 'transfer id', stripe_account_id: nil, amount: '1234')
      expect(Payment.count).to eq(0)
    end

    it 'creates a market payment for the transfer amount and releated orders' do
      payment = double(id: 187)
      expect(PaymentProvider::Stripe).to receive(:order_ids_for_market_payout_transfer).
        with(transfer_id: 'transfer id', stripe_account_id: 'account id').
        and_return(['123', '456'])
      expect(PaymentProvider::Stripe).to receive(:create_market_payment).
        with(transfer_id: 'transfer id', market: market, order_ids: ['123', '456'], 
             status: 'paid', amount: '12.34'.to_d).
        and_return(payment)
      expect(PaymentMailer).to receive(:payment_received).with([user], 187)

      subject.handle(transfer_id: 'transfer id', stripe_account_id: 'account id', 
                     amount: '1234')
    end
  end
end
