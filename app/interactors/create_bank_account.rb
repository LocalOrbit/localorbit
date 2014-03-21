class CreateBankAccount
  include Interactor

  def perform
    context[:bank_account] = entity.bank_accounts.create!(bank_account_params)
  end
end
