class AddCreditCardToStripeCustomer
  include Interactor

  def perform
    stripe_customer = context[:stripe_customer]
    bank_account = context[:bank_account]
    stripe_tok = context[:bank_account_params][:stripe_tok]

    stripe_card = PaymentProvider::Stripe.create_stripe_card_for_stripe_customer(
      stripe_customer_id: stripe_customer.id,
      stripe_tok: stripe_tok
    )

    bank_account.update(stripe_id: stripe_card.id)
  end
end
