class BankAccountVerification
  include ActiveModel::Model

  attr_accessor :amount_1, :amount_2, :bank_account, :attempt

  validates :amount_1, :amount_2, numericality: {greater_than: 0, less_than: 100, only_integer: true}

  def attempt
    balanced_bank_account = Balanced::BankAccount.find(bank_account.balanced_uri)
    balanced_verification = Balanced::Verification.find(balanced_bank_account.verification_uri)

    balanced_verification.attempts + 1
  end

  def save
    if valid?
      results = VerifyBankAccount.perform(
        bank_account: bank_account,
        verification_params: {amount_1: amount_1, amount_2: amount_2})

      if !results.success?
        errors[:base] << "Could not verify bank account."
        false
      else
        true
      end
    else
      false
    end
  end

  def persisted?
    true
  end
end
