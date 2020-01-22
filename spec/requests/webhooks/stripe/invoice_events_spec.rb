# coding: utf-8
require 'spec_helper'

describe 'invoice.payment_succeeded webhook', type: :request, vcr: false do
  let(:stripe_customer_id) {'cus_9aUcniAOYTXn42'} # matches invoice.payment_succeeded.json
  let(:stripe_charge_id) {'ch_19HJd82VpjOYk6TmrzJdKLYR'} # matches invoice.payment_succeeded.json
  let(:stripe_card_id) {'card_19HJd62VpjOYk6TmwKcemuLf'} # matches card related to invoice.payment_succeeded.json charge

  let!(:organization) { create(:organization, stripe_customer_id: stripe_customer_id, org_type: Organization::TYPE_MARKET) }
  let!(:market) { create(:market, stripe_customer_id: stripe_customer_id, organization_id: organization.id) }
  let!(:market_2) { create(:market, stripe_customer_id: stripe_customer_id + 'KXM') }
  let!(:credit_card) { create(:bank_account, bankable: market, stripe_id: stripe_card_id) }

  before(:all) { StripeMock.start }
  after(:all)  { StripeMock.stop }

  it 'finds the related organization' do
    expect(find_stripe_market(stripe_customer_id).count).to eq 1
  end

  it 'errors out on no related organization' do end

  it 'confirms payment as new and unique' do
    expect(find_payment(stripe_charge_id).count).to eq 0
  end

  it 'disregards invoices that aren’t for subscriptions' do
    # This is a contrivance to allow for testing until a like event is recorded for something _other than_ a subscription.  At such time, any reference to the subscription status (within the webhook 'domain') should be updated to reflect any new knowledge.  If that's you, then 'TAG', you're it.

    # Generate a Stripe invoice that isn't related to a subscription and use that instead
    missing_subscription = {
      id: 'evt_19NxEZ2VpjOYk6TmQLjYsn5Y',
      data: {
        object: {
          id: 'in_19NwIT2VpjOYk6TmuXa5PSFl',
          amount_due: 500,
          charge: 'ch_19NxEY2VpjOYk6TmlDvEqqAX',
          customer: 'cus_9gwCSjIO6SlmhA',
        }
      },
      livemode: false,
      type: 'invoice.payment_successful'
    }

    event = Stripe::Event.construct_from(missing_subscription)

    initial_count = find_payment(event.data.object.charge).count

    post '/webhooks/stripe', event.as_json
    expect(response.status).to eq 200

    expect(find_payment(event.data.object.charge).count).to eq initial_count
  end

  it 'creates a new payment object' do
    initial_count = find_payment(stripe_charge_id).count

    post '/webhooks/stripe', JSON.parse(File.read('spec/fixtures/stripe_webhooks/invoice.payment_succeeded.json'))
    expect(response.status).to eq 200

    expect(find_payment(stripe_charge_id).count).to eq initial_count + 1
  end
end

describe 'invoice.payment_failed webhook', type: :request, vcr: true do
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
    post '/webhooks/stripe', JSON.parse(File.read('spec/fixtures/stripe_webhooks/invoice.payment_failed.json'))
    expect(response.status).to eq 200

    expect(Payment.all.count).to eq base
    expect(existing_payment.status).to eq failed_payment.status
  end

  it 'creates a new payment record if necessary' do
    post '/webhooks/stripe', JSON.parse(File.read('spec/fixtures/stripe_webhooks/invoice.payment_failed.json'))
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
