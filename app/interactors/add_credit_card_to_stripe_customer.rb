class AddCreditCardToStripeCustomer
  include Interactor

  CardSchema = ::PaymentProvider::Stripe::CardSchema

  def perform
    entity = context[:entity]
    card_params = (context[:bank_account_params] || {}).symbolize_keys

    SchemaValidation.validate!(CardSchema::SubmittedParams, card_params)

    stripe_tok = card_params.delete(:stripe_tok)

    PaymentProvider::Stripe.create_stripe_card_for_bankable(
      entity: entity,
      card_params: card_params,
      stripe_tok: stripe_tok)
  end
end
