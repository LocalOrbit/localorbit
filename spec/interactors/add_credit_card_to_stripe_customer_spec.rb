describe AddCreditCardToStripeCustomer do
  subject { described_class }


  let(:params) {
    {
      entity: "the entity",
      bank_account_params: card_params,
      representative_params: "not currently used"
    }
  }

  let(:card_params) {
    HashWithIndifferentAccess.new({ name: 'my the name',
      bank_name:"the bank name",
      last_four:"1234",
      stripe_tok:"the tok",
      account_type:"the account type",
      expiration_month:"the month",
      expiration_year:"the year",
      notes:"some notes" })
  }

  it "pass params along to Stripe.create_stripe_card_for_bankable" do
    expected_card_params = card_params.symbolize_keys
    expected_card_params.delete(:stripe_tok)

    expect(PaymentProvider::Stripe).to receive(:create_stripe_card_for_bankable).with(
      entity: "the entity",
      card_params: expected_card_params,
      stripe_tok: "the tok"
    )

    subject.perform(params)
  end

  it "validates the structure of card_params" do
    expect(PaymentProvider::Stripe).not_to receive(:create_stripe_card_for_bankable)

    params[:bank_account_params].delete(:stripe_tok)
    expect do subject.perform(params) end.to raise_error(/missing.*stripe_tok/)
  end
end
