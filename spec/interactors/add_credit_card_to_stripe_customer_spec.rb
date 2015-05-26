describe AddCreditCardToStripeCustomer do
  subject { described_class }


  let(:stripe_customer) { double "the stripe cust", id: 'stripe cust id' }
  let(:bank_account) { double "the bank acct" }
  let(:stripe_card) { double "the stripe card", id: 'stripe card id' }
  let(:stripe_tok) { "the stripe token id" }

  let(:params) {
    {
      entity: "the unused entity",
      stripe_customer: stripe_customer,
      bank_account: bank_account,
      bank_account_params: HashWithIndifferentAccess.new(stripe_tok: stripe_tok),
      representative_params: "not currently used"
    }
  }

  it "creates a stripe credit card and plugs it into the bank account" do
    expect(PaymentProvider::Stripe).to receive(:create_stripe_card_for_stripe_customer).with(
      stripe_customer_id: stripe_customer.id,
      stripe_tok: stripe_tok
    ).and_return(stripe_card)

    expect(bank_account).to receive(:update).with(stripe_id: stripe_card.id)

    result = subject.perform(params)

    expect(result.success?).to be true
  end

end
