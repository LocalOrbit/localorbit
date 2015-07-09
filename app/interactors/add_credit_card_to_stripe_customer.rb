class AddCreditCardToStripeCustomer
  include Interactor

  def perform
    stripe_customer = context[:stripe_customer]
    bank_account = context[:bank_account]
    stripe_tok = context[:bank_account_params][:stripe_tok]

    begin
      stripe_card = PaymentProvider::Stripe.create_stripe_card_for_stripe_customer(
        stripe_customer_id: stripe_customer.id,
        stripe_tok: stripe_tok
      )

      bank_account.update(stripe_id: stripe_card.id)

    rescue Exception => e
      bank_account.destroy
      context[:bank_account] = nil
      error_info = ErrorReporting.interpret_exception(e)
      Honeybadger.notify_or_ignore(error_info[:honeybadger_exception])
      context[:error] = error_info[:application_error_message]
      context.fail!
    end
  end

end
