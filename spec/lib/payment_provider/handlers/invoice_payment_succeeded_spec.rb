# coding: utf-8
require 'spec_helper'

xdescribe 'invoice.payment_succeeded webhook', type: :request, vcr: false do
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

    post '/webhooks/stripe', JSON.parse(File.read('spec/fixtures/webhooks/stripe/invoice.payment_succeeded.json'))
    expect(response.status).to eq 200

    expect(find_payment(stripe_charge_id).count).to eq initial_count + 1
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
