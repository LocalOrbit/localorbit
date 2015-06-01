require 'spec_helper'

describe CreateManagedStripeAccountForMarket do
  subject { described_class }

  before { VCR.turn_off! }
  after { VCR.turn_on! }


  let!(:market) { create(:market, 
                         name:          "My New Market", 
                         contact_email: "newmart@example.com") }

  it "generates a new managed Stripe account" do
    results = subject.perform(market: market)
    expect(results.success?).to be true

    stripe_account = results.stripe_account
    expect(stripe_account).to be

    expect(market.reload.stripe_account_id).to be
    expect(market.reload.stripe_account_id).to eq stripe_account.id

    expect(stripe_account.managed).to be true
    expect(stripe_account.email).to eq market.contact_email
    expect(stripe_account.business_name).to eq market.name
    expect(stripe_account.country).to eq 'US'
    expect(stripe_account.debit_negative_balances).to be true
    expect(stripe_account.metadata).to be
    expect(stripe_account.metadata['lo.market_id']).to eq market.id.to_s
    
    # Check the transfer schedule (determined by PaymentProvider::Stripe::TransferSchedule)
    expect(stripe_account.transfer_schedule.delay_days).to eq 5
    expect(stripe_account.transfer_schedule.interval).to eq 'weekly'
    expect(stripe_account.transfer_schedule.weekly_anchor).to eq 'wednesday'
  end

  context "when Market already has a Stripe account" do
    let!(:stripe_account) { get_or_create_stripe_account_for_market(market) }

    it "sets the existing stripe_account into the results instead of making new" do
      # Sanity check the market/account relationship:
      expect(stripe_account).to be
      existing_account_id = market.reload.stripe_account_id
      expect(existing_account_id).to eq stripe_account.id

      # Do not want for calls to .create:
      expect(Stripe::Account).not_to receive(:create)

      # Go!
      results = subject.perform(market: market)
      expect(results.success?).to be true

      expect(market.reload.stripe_account_id).to eq existing_account_id
      expect(results.stripe_account.id).to eq stripe_account.id
    end
  end
end
