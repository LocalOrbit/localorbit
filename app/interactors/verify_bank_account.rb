class VerifyBankAccount
  include Interactor

  def setup
    context[:verification] ||= bank_account.balanced_verification
  end

  def perform
    verification.amount_1 = verification_params[:amount_1]
    verification.amount_2 = verification_params[:amount_2]

    begin
      verification.save
    rescue Balanced::BankAccountVerificationFailure
      fail!
    end
    fail! unless verified?

    bank_account.update_attribute(:verified, verified?)
  end

  def verified?
    verification.state == "verified"
  end
end
