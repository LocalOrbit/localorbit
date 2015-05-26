class CreateBankAccount
  include Interactor

  def perform
    params = bank_account_params.dup
    params.delete(:stripe_tok)
    context[:bank_account] = entity.bank_accounts.create(params)

    unless context[:bank_account].valid?
      context.fail!
    end
  end
end
