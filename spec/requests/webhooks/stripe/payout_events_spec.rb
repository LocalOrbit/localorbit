require 'spec_helper'

describe 'Payout Events' do
  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }
  before(:each) { bypass_event_signature payload }

  describe 'payout.paid' do
    let(:payload) { File.read('spec/fixtures/webhooks/stripe/payout.paid.json') }
    let!(:market) { create(:market, stripe_account_id: 'acct_1Ey0S0E6YF0s1lCh') }

    it 'is successful' do
      post '/webhooks/stripe', body: payload
      expect(response).to be_success
    end

    it 'sends create_market_payment to Stripe provider' do
      expect(PaymentProvider::Stripe).to receive(:order_ids_for_market_payout_transfer)
      expect(PaymentProvider::Stripe).to receive(:create_market_payment).with(hash_including(market: market, amount: 118.86))
      post '/webhooks/stripe', body: payload
    end
  end
end