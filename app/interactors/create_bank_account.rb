class CreateBankAccount
  include Interactor

  def setup
    # Out of the original intent, this interactor fails at entity.bank_accounts.create(params) without this setup
    context[:entity] ||= context[:market] || context[:organization]
  end

  def perform
    # 'context[:bank_account_params]'' is defined in markets_controller for Roll Your Own.  It is an add-on 
    # and is drastically under-populated compared to the pre-existing 'bank_account_params.dup'In this 
    # context, the created bank account contains no actual data.  That seems weird, but then so does our 
    # storing of the account data... 
    params = context[:bank_account_params] || bank_account_params.dup
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
