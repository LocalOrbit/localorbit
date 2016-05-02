class CreateBankAccount
  include Interactor

  def setup
    # Out of the original context and without this setup, the interactor fails at entity.bank_accounts.create(params)
    context[:entity]    ||= context[:market] || context[:organization]
    bank_account_params ||= context[:bank_account_params]
  end

  def perform

    if(
      # If the supplied bank_account_params constitute a Stripe Card...
      bank_account_params.class == Stripe::Card &&
      # ...and the card is for this Stripe customer
      context[:entity].try(:stripe_customer_id) == params.bank_account_params
    )
      # ...then use the card to create the bank account.
      params = extract_stripe_card_attributes(params)

    else
      # Otherwise, use the supplied hash
      params = bank_account_params.dup
      params.delete(:stripe_tok)
    end

    context[:bank_account] = entity.bank_accounts.create(params)

    unless context[:bank_account].valid?
      context.fail!(error: "Could not create bank account record in database")
    end
  end

  def rollback
    if bank_account = context[:bank_account]
      bank_account.destroy
    end
  end

  def extract_stripe_card_attributes(params)
    ret_val = {
      bank_name: params.brand,
      last_four: params.last4,
      account_type: params.object,
      verified: true,
      bankable_type: 'Market',
      expiration_month: params.exp_month,
      expiration_year: params.exp_year,
      stripe_id: params.id
    }
  end
end
