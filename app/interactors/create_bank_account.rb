class CreateBankAccount
  include Interactor

  def setup
    # Out of the original context and without this setup, the interactor fails at entity.bank_accounts.create(params)
    context[:entity] ||= context[:market] || context[:organization]
  end

  def perform
    params = bank_account_params.dup
    if stripe_cust = context[:stripe_customer]
      params[:notes] = "Stripe customer id: #{stripe_cust.id}"
    end

    params.delete(:stripe_tok)
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
end
