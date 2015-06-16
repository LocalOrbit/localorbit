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
      Honeybadger.notify_or_ignore(e)
      error_message = determine_error_message(e)
      context[:error] = error_message
      context.fail!
    end
  end

  def determine_error_message(e)
    message = case e
              when ::Stripe::StripeError
                if e.respond_to?(:json_body) and data = e.json_body
                  if err = data[:error] 
                    err[:message]
                  end
                end
              end
    return (message || "An unexpected error occurred.")
  end

end
