class AddCreditCardToStripeCustomer
  include Interactor

  CardSchema = ::PaymentProvider::Stripe::CardSchema

  def perform
    entity = context[:entity]
    card_params = (context[:bank_account_params] || {}).symbolize_keys
    bank_account = context[:bank_account]

    SchemaValidation.validate!(CardSchema::SubmittedParams, card_params)

    stripe_tok = card_params.delete(:stripe_tok)

    card = PaymentProvider::Stripe.create_stripe_card_for_stripe_customer(
      stripe_customer_id: entity.stripe_customer_id,
      stripe_tok: stripe_tok
    )

    bank_account.update(stripe_id: card.id)
  end
end
