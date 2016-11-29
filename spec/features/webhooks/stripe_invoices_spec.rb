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

  it "confirms payment as new and unique" do
    expect(find_payment(stripe_charge_id).count).to eq 0
  end

  # it "disregards invoices that aren't for subscriptions" do
  #   # Is this a thing?
  # end

  it "creates a new payment object" do
    response = post '/webhooks/stripe', JSON.parse(File.read('spec/features/webhooks/invoice.payment_succeeded.json'))
    expect(response.status).to eq 200

    expect(find_payment(stripe_charge_id).count).to eq 1
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

end
