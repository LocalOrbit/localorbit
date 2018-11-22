# coding: utf-8
require 'spec_helper'

describe 'invoice.payment_succeeded webhook', type: :request, vcr: true do
  let(:stripe_customer_id) {'cus_9aUcniAOYTXn42'} # matches invoice.payment_succeeded.json
  let(:stripe_charge_id) {'ch_19HJd82VpjOYk6TmrzJdKLYR'} # matches invoice.payment_succeeded.json
  let(:stripe_card_id) {'card_19HJd62VpjOYk6TmwKcemuLf'} # matches card related to invoice.payment_succeeded.json charge

  let!(:organization) { create(:organization, stripe_customer_id: stripe_customer_id, org_type: Organization::TYPE_MARKET) }
  let!(:market) { create(:market, stripe_customer_id: stripe_customer_id, organization_id: organization.id) }
  let!(:credit_card) { create(:bank_account, bankable: market, stripe_id: stripe_card_id) }

  it 'response status is 200' do
    post_webhook('invoice.payment_succeeded')
    expect(response.status).to eq 200
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
    expect { post '/webhooks/stripe', event.as_json }.to_not change { Payment.count }
  end

  it 'creates a new payment object' do
    expect { post_webhook('invoice.payment_succeeded') }.to change { Payment.count }.by(1)
  end
end

describe 'invoice.payment_failed webhook', type: :request, vcr: true do
  let(:stripe_customer_id) {'cus_9gwCSjIO6SlmhA'} # matches invoice.payment_failed.json
  let(:stripe_charge_id) {'ch_19NxEY2VpjOYk6TmlDvEqqAX'} # matches invoice.payment_failed.json
  let(:stripe_card_id) {'card_19HJd62VpjOYk6TmwKcemuLf'} # matches card related to invoice.payment_failed.json charge

  let!(:organization) { create(:organization, stripe_customer_id: stripe_customer_id, org_type: Organization::TYPE_MARKET) }
  let!(:market) { create(:market, stripe_customer_id: stripe_customer_id, organization_id: organization.id) }
  let!(:credit_card) { create(:bank_account, bankable: market, stripe_id: stripe_card_id) }

  it 'response status is 200' do
    post_webhook('invoice.payment_failed')
    expect(response).to have_http_status(:ok)
  end

  context 'with existing payment' do
    let!(:existing_payment) { create(:payment, :stripe_subscription,
                                     stripe_id: stripe_charge_id,
                                     market_id: market.id,
                                     organization_id: market.organization_id,
                                     payer_id: market.organization_id) }

    it 'correctly updates an existing payment record' do
      expect { post_webhook('invoice.payment_failed') }.not_to change { Payment.count }
      expect(existing_payment.reload.status).to eq 'failed'
    end
  end

  context 'without existing payment' do
    it 'creates a new payment record' do
      expect { post_webhook('invoice.payment_failed')}.to change { Payment.count }.by(1)
    end
  end

  it 'sends a failed_payment email' do
    expect(WebhookMailer).to receive_message_chain(:delay, :failed_payment)
    post_webhook('invoice.payment_failed')
  end
end

def find_payment(stripe_charge_id)
  Payment.where(stripe_id: stripe_charge_id)
end
