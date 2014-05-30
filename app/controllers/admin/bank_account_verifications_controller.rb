class Admin::BankAccountVerificationsController < AdminController
  include BankAccountEntity

  def show
    @verification = BankAccountVerification.new
    @verification.bank_account = find_bank_account
    render @verification.failed? ? "verification_failed" : "show"
  end

  def update
    @verification = BankAccountVerification.new(verification_params)
    @verification.bank_account = find_bank_account

    if @verification.save
      redirect_to [:admin, @entity, :bank_accounts]
    else
      if @verification.failed?
        redirect_to [:admin, @entity, :bank_accounts], alert: "Bank account verification failed."
      else
        flash.now[:alert] = "Could not verify bank account."
        render "show"
      end
    end
  end

  private

  def find_bank_account
    @entity.bank_accounts.find(params[:bank_account_id])
  end

  def verification_params
    params.require(:bank_account_verification).permit(:amount_1, :amount_2)
  end
end
