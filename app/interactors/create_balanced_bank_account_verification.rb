class CreateBalancedBankAccountVerification
  include Interactor

  def setup
    context[:balanced_bank_account] ||= Balanced::BankAccount.find(bank_account.balanced_uri)
  end

  def perform
    verification = balanced_bank_account.verify
    bank_account.update_attributes(balanced_verification_uri: verification.uri)
  end
end
