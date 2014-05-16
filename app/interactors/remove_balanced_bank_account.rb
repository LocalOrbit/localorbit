class RemoveBalancedBankAccount
  include Interactor

  def setup
    context[:balanced_bank_account] ||= Balanced::BankAccount.find(bank_account.balanced_uri)
  end

  def perform
    balanced_bank_account.destroy if balanced_bank_account
  end
end
