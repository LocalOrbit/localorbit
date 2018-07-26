require 'spec_helper'

RSpec.describe 'Stripe invoice events', :vcr, type: :request do
  before(:each) { bypass_event_signature payload }

  describe 'invoice.payment_succeeded' do
    let(:stripe_customer_id) {'cus_9aUcniAOYTXn42'} # matches invoice.payment_succeeded.json
    let(:stripe_charge_id) {'ch_19HJd82VpjOYk6TmrzJdKLYR'} # matches invoice.payment_succeeded.json
    let(:stripe_card_id) {'card_19HJd62VpjOYk6TmwKcemuLf'} # matches card related to invoice.payment_succeeded.json charge

    let!(:organization) { create(:organization, stripe_customer_id: stripe_customer_id, org_type: 'M') }

    context 'no subscription' do
      # This is a contrivance to allow for testing until a like event is recorded for
      # something _other than_ a subscription.  At such time, any reference to the subscription
      # status (within the webhook 'domain') should be updated to reflect any new knowledge.
      # If that's you, then 'TAG', you're it.

      # Generate a Stripe invoice that isn't related to a subscription and use that instead
      let(:payload) { File.read('spec/fixtures/webhooks/stripe/invoice.payment_succeeded.no_sub.json') }
      let(:charge) { 'ch_19NxEY2VpjOYk6TmlDvEqqAX' }

      it 'disregards invoices that are not for subscriptions' do
        initial_count = payment_count(charge)

        post '/webhooks/stripe', payload
        expect(response).to have_http_status(:ok)
        expect(payment_count(charge)).to eq initial_count
      end
    end

    context 'with subscription' do
      let(:payload) { File.read('spec/fixtures/webhooks/stripe/invoice.payment_succeeded.json') }

      it 'creates a new payment object' do
        initial_count = payment_count(stripe_charge_id)

        post '/webhooks/stripe', payload
        expect(response).to have_http_status(:ok)

        expect(payment_count(stripe_charge_id)).to eq initial_count + 1
      end
    end
  end

  describe 'invoice.payment_failed' do
    let(:stripe_customer_id) {'cus_9gwCSjIO6SlmhA'} # matches invoice.payment_failed.json
    let(:stripe_charge_id) {'ch_19NxEY2VpjOYk6TmlDvEqqAX'} # matches invoice.payment_failed.json

    let(:market) { create(:market) }
    let!(:organization) { create(:organization, market: market, stripe_customer_id: stripe_customer_id) }
    let!(:organization2) { create(:organization, stripe_customer_id: stripe_customer_id + 'KXM') }

    let!(:existing_payment) { create(:payment, :stripe_subscription, stripe_id: stripe_charge_id,
                                     market_id: market.id, organization_id: organization.id,
                                     payer_id: organization.id) }
    let!(:failed_payment) { create(:payment, status: 'failed') }
    let(:payload) { File.read('spec/fixtures/webhooks/stripe/invoice.payment_failed.json') }


    it 'correctly updates an existing payment record' do
      initial_count = Payment.all.count
      post '/webhooks/stripe', payload

      expect(response).to have_http_status(:ok)
      expect(Payment.all.count).to eq initial_count
      expect(existing_payment.reload.status).to eq failed_payment.status
    end

    it 'creates a new payment record if necessary' do
      post '/webhooks/stripe', payload

      expect(response).to have_http_status(:ok)
      expect(payment_count(stripe_charge_id)).to eq 1
    end
  end
end

def payment_count(stripe_charge_id)
  Payment.where(stripe_id: stripe_charge_id).count
end
