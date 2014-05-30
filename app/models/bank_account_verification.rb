class BankAccountVerification
  include ActiveModel::Model

  attr_accessor :amount_1, :amount_2, :bank_account

  validates :amount_1, :amount_2, numericality: {greater_than: 0, less_than: 100, only_integer: true}

  def attempts
    bank_account.balanced_verification.try(:attempts)
  end

  def remaining_attempts
    bank_account.balanced_verification.try(:remaining_attempts)
  end

  def state
    bank_account.balanced_verification.try(:state) || "missing"
  end

  def save
    return false unless valid?

    results = VerifyBankAccount.perform(
      bank_account: bank_account,
      verification_params: {amount_1: amount_1, amount_2: amount_2})

    errors.add(:base, "Could not verify bank account.") unless results.success?

    results.success?
  end

  def persisted?
    true
  end
end
