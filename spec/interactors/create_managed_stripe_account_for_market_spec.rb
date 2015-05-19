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
  end
end
