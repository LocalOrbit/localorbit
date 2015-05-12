class AddCreditCardToStripeCustomer
  include Interactor

  def setup
    # context[:balanced_customer] ||= entity.balanced_customer
  end

  def perform
    raise "AddCreditCardToStripeCustomer is not yet implemented!"
    entity = context[:entity]
    card_params = context[:bank_account_params]
    # TODO : test with inputs of this shape, which is submitted via BankAccounts controller:
# {"bank_name"=>"Visa",
#  "last_four"=>"1881",
#  "stripe_tok"=>"tok_161Qw82VpjOYk6Tmmpy1Uz0r",
#  "account_type"=>"card",
#  "expiration_month"=>"5",
#  "expiration_year"=>"2018",
#  "notes"=>""}
    stripe_tok = card_params.delete(:stripe_tok)

    PaymentProvider::Stripe.create_stripe_card_for_bankable(
      entity: entity
      card_params: card_params,
      stripe_tok: stripe_tok)
  end
end
