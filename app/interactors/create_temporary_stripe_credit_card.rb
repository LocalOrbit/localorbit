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

    # Munge card params:
    should_save_card = credit_card_params.delete(:save_for_future) == "true"
    unless should_save_card
      credit_card_params.merge!(deleted_at: Time.current)
    end
    stripe_tok = credit_card_params.delete(:stripe_tok)
    credit_card_params.delete(:id)
    SchemaValidation.validate!(CardSchema::NewParams, credit_card_params)

    bank_account = if existing_bank_account = find_bank_account(@org, credit_card_params)
                     # use this account
                     existing_bank_account
                   else
                     # create new card in Stripe and add to our Stripe customer
                     create_stripe_card_bank_account(@org, stripe_tok, credit_card_params)
                   end
    
    set_card_for_transaction(bank_account)
  end

  private

  def find_bank_account(org, params)
    org.bank_accounts.visible.where(
      # account_type: params[:account_type], # XXX during the May 2015 Balanced-Stripe migration, we boiled-down account_type for CC's to "card" instead of "mastercard", "visa" etc. In transition we might fail a match if we use this field. crosby 5/11
      last_four: params[:last_four],
      bank_name: params[:bank_name],
      name: params[:name]
    ).first
  end

  def set_card_for_transaction(bank_account)
    context[:order_params]["credit_card"]["id"] = bank_account.id
  end

  def create_stripe_card_bank_account(org, stripe_tok, card_params)
    PaymentProvider::Stripe.create_stripe_card_for_bankable(
      organization: org,
      card_params: card_params,
      stripe_tok: stripe_tok)

  rescue => e
    if Rails.env.test? || Rails.env.development?
      raise e
    else
      Honeybadger.notify_or_ignore(e)
    end
    context[:order].errors.add(:credit_card, "was denied by the payment processor.")
    context.fail!
  end



end
