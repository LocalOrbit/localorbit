class CreateBankAccount
  include Interactor

  def setup
    # Out of the original context and without this setup, the interactor fails at entity.bank_accounts.create(params)
    context[:entity]    ||= context[:market] || context[:organization]
    bank_account_params ||= context[:bank_account_params]
  end

  def perform
    entity = context[:RYO] == true ? context[:organization] : context[:entity]
    if(
      # If the supplied bank_account_params identify this Stripe customer...
      context[:entity].try(:stripe_customer_id) == bank_account_params.try(:customer) &&
      # ...and constitute an accepted Stripe object...
      (
          bank_account_params.class == Stripe::Card ||
          bank_account_params.class == Stripe::BankAccount
      )
    )
      # ...then use the card to create the bank account.
      params = extract_stripe_card_attributes(bank_account_params)

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
    case params.object
    when "bank_account"
      ret_val = {
        bank_name: params.bank_name,
        name: params.account_holder_name,
        last_four: params.last4,
        account_type: "checking",
        bankable_type: "Market",
        stripe_id: params.id
      }
      ret_val[:verified] = true if params.status == "verified"

    when "card"
      ret_val = {
        bank_name: params.brand,
        name: params.name,
        last_four: params.last4,
        account_type: params.object,
        verified: true,
        bankable_type: "Market",
        expiration_month: params.exp_month,
        expiration_year: params.exp_year,
        stripe_id: params.id
      }

      ret_val
    end
  end
end
