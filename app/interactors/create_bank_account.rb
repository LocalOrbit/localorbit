class CreateBankAccount
  include Interactor

  def setup
    # Out of the original context and without this setup, the interactor fails at entity.bank_accounts.create(params)
    context[:entity] ||= context[:market] || context[:organization]
  end

  def perform
    params = bank_account_params.dup

    # KXM Why is the token deleted here?
    params.delete(:stripe_tok)
    context[:bank_account] = entity.bank_accounts.create(params)

    # KXM This is nice and clean, but is there an operation error that is better captured and reported?
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
