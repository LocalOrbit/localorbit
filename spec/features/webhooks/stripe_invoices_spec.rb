require 'spec_helper'

describe "stripe invoice.payment_succeeded event", vcr: true, webhook: true do
  let(:stripe_customer_id) {'cus_9aUcniAOYTXn42'} # matches invoice.payment_succeeded.json
  let(:stripe_charge_id) {'ch_19HJd82VpjOYk6TmrzJdKLYR'} # matches invoice.payment_succeeded.json
  let(:stripe_card_id) {'card_19HJd62VpjOYk6TmwKcemuLf'} # matches card related to invoice.payment_succeeded.json charge

  let!(:market) { create(:market, stripe_customer_id: stripe_customer_id) }
  let!(:market_2) { create(:market, stripe_customer_id: stripe_customer_id + 'KXM') }
  let!(:credit_card) { create(:bank_account, bankable: market, stripe_id: stripe_card_id) }

  it "finds the related organization" do
    expect(find_stripe_market(stripe_customer_id).count).to eq 1
  end

  it "errors out on no related organization" do end

  it "confirms payment as new and unique" do
    expect(find_payment(stripe_charge_id).count).to eq 0
  end

  xit "disregards invoices that aren't for subscriptions" do
    # KXM nullifying the subscription doesn't work because the webhook retrieves the data from Stripe directly
    # Generate a Stripe invoice that isn't related to a subscription and use that instead
    initial_count = find_payment(stripe_charge_id).count

    response = post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/invoice.payment_failed.json'))
    expect(response.status).to eq 200

    expect(find_payment(stripe_charge_id).count).to eq initial_count
  end

  it "creates a new payment object" do
    initial_count = find_payment(stripe_charge_id).count
    
    response = post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/invoice.payment_succeeded.json'))
    expect(response.status).to eq 200

    expect(find_payment(stripe_charge_id).count).to eq initial_count + 1
  end
end

describe "stripe invoice.payment_failed event", vcr: true, webhook: true do
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

  it "finds the related organization" do
  end

  it "finds the related bank_account record" do
  end

  it 'correctly updates an existing payment record' do
    base = Payment.all.count
    response = post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/invoice.payment_failed.json'))
    expect(response.status).to eq 200

    expect(Payment.all.count).to eq base
    expect(existing_payment.status).to eq failed_payment.status
  end

  it 'creates a new payment record if necessary' do
    response = post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/invoice.payment_failed.json'))
    expect(response.status).to eq 200

    # expect(find_payment(stripe_charge_id).count).to eq 1
  end

end


#
# HELPERS
#

def find_stripe_market(stripe_customer_id)
  Market.where(stripe_customer_id: stripe_customer_id)
end

def find_payment(stripe_charge_id)
  Payment.where(stripe_id: stripe_charge_id)
end
