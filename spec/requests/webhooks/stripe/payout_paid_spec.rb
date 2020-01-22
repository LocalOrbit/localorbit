# coding: utf-8
require 'spec_helper'

describe 'payout.paid webhook', type: :request, vcr: false do
  let(:stripe_account_id) { 'acct_15xJY9HouQbaP1MV' }
  let(:stripe_transfer_id) { 'tr_15xxwkHouQbaP1MV8O0tEg2b' }
  let!(:market) { create(:market, stripe_account_id: stripe_account_id) }
  let!(:merri) { create(:user, :market_manager, name: 'Merri', managed_markets: [market]) }
  let!(:orders) { create_list(:order, 3, market: market) }

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it 'creates a payment and emails the market’s managers' do
    expect(Rollbar).to_not receive(:info)
    expect(PaymentProvider::Stripe).to receive(:create_market_payment)
    expect(Financials::PaymentNotifier).to receive(:market_payment_received)

    PaymentProvider::Handlers::PayoutPaid.handle(transfer_id: stripe_transfer_id, stripe_account_id: stripe_account_id, amount_in_cents: 33210)
  end

  def find_payments
    Payment.where(payee: market)
  end

  def forcibly_change_order_id(order, new_id)
    Order.where(id:order.id).update_all(id: new_id) # not something you'd normally do
  end
end
