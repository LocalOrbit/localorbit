# coding: utf-8
require 'spec_helper'

xdescribe 'invoice.payment_failed webhook', type: :request, vcr: false do
  let(:stripe_customer_id) {'cus_9aUcniAOYTXn42'} # matches invoice.payment_failed.json
  let(:stripe_charge_id) {'ch_19HJd82VpjOYk6TmrzJdKLYR'} # matches invoice.payment_failed.json
  let(:stripe_card_id) {'card_19HJd62VpjOYk6TmwKcemuLf'} # matches card related to invoice.payment_failed.json charge

  let!(:market) { create(:market, stripe_customer_id: stripe_customer_id) }
  let!(:market_2) { create(:market, stripe_customer_id: stripe_customer_id + 'KXM') }
  let!(:credit_card) { create(:bank_account, bankable: market, stripe_id: stripe_card_id) }

  let!(:existing_payment) { create(:payment, :stripe_subscription, stripe_id: stripe_charge_id, market_id: market.id, organization_id: market.organization_id, payer_id: market.organization_id) }

  let!(:failed_payment) { create(:payment) }

  before do
    failed_payment.failed
  end

  it 'finds the related organization' do
    expect(find_stripe_market(stripe_customer_id).count).to eq 1
  end

  it 'finds the related bank_account record' do
    expect(find_bank_account(stripe_card_id).count).to eq 1
  end

  it 'correctly updates an existing payment record' do
    base = Payment.all.count
    post '/webhooks/stripe', JSON.parse(File.read('spec/fixtures/webhooks/stripe/invoice.payment_failed.json'))
    expect(response.status).to eq 200

    expect(Payment.all.count).to eq base
    expect(existing_payment.status).to eq failed_payment.status
  end

  it 'creates a new payment record if necessary' do
    post '/webhooks/stripe', JSON.parse(File.read('spec/fixtures/webhooks/stripe/invoice.payment_failed.json'))
    expect(response.status).to eq 200

    # expect(find_payment(stripe_charge_id).count).to eq 1
  end

end

def find_stripe_market(stripe_customer_id)
  Market.where(stripe_customer_id: stripe_customer_id)
end

def find_payment(stripe_charge_id)
  Payment.where(stripe_id: stripe_charge_id)
end

def find_bank_account(stripe_card_id)
  BankAccount.where(stripe_id: stripe_card_id)
end
