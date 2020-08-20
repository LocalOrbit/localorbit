class CreateTemporaryStripeCreditCard
  include Interactor

  CardSchema = ::PaymentProvider::Stripe::CardSchema

  def perform
    # This interactor is only for credit cards
    return unless "credit card" == order_params[:payment_method]

    credit_card_params = order_params["credit_card"].to_hash.symbolize_keys

    # ...only for cards that aren't already on file:
    return unless credit_card_params[:id].blank?
    SchemaValidation.validate!(CardSchema::SubmittedParams, credit_card_params)

    @org = cart.organization

    should_save_card = credit_card_params.delete(:save_for_future) == "true"
    unless should_save_card
      credit_card_params.merge!(deleted_at: Time.current)
    end
    stripe_tok = credit_card_params.delete(:stripe_tok)
    credit_card_params.delete(:id)
    SchemaValidation.validate!(CardSchema::NewParams, credit_card_params)

    bank_account = find_bank_account(@org, credit_card_params) || create_stripe_card_bank_account(@org, stripe_tok, credit_card_params)
    if bank_account
      # create_stripe_card_bank_account could fail and return nil, in which case the context has been failed, and we cannot set the card for the transaction
      set_card_for_transaction(bank_account)
    end
  end

  private

  def find_bank_account(org, params)
    org.bank_accounts.visible.find_by(
      last_four: params[:last_four],
      expiration_month: params[:expiration_month],
      expiration_year: params[:expiration_year],
      bank_name: params[:bank_name],
      name: params[:name]
    )
  end

  def set_card_for_transaction(bank_account)
    context[:order_params]["credit_card"]["id"] = bank_account.id
  end

  def create_stripe_card_bank_account(org, stripe_tok, card_params)
    bank_account = nil

    begin
      SchemaValidation.validate!(CardSchema::NewParams, card_params)

      card = PaymentProvider::Stripe.create_stripe_card_for_stripe_customer(
        stripe_customer_id: org.stripe_customer_id,
        stripe_tok: stripe_tok
      )
      bank_account = org.bank_accounts.create!(card_params.merge(stripe_id: card.id))

    rescue => e
      Rails.logger.info "temp credit card"
      Rails.logger.info e
      error_info = ErrorReporting.interpret_exception(e)

      Rails.logger.info error_info
      Rollbar.info(e)

      context[:order].errors.add(:credit_card, ": #{error_info[:application_error_message]}")
      context.fail!
    end

    bank_account
  end
end
