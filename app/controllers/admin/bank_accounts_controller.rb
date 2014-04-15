class Admin::BankAccountsController < AdminController
  include BankAccountEntity

  def index
    @bank_accounts = @entity.bank_accounts
  end

  def new
    @bank_account = @entity.bank_accounts.build
  end

  def create
    results = if params[:type] == "card"
      AddCreditCardToEntity.perform(entity: @entity, bank_account_params: bank_account_params)
    else
      AddBankAccountToEntity.perform(entity: @entity, bank_account_params: bank_account_params, representative_params: representative_params)
    end

    if results.success?
      redirect_to [:admin, @entity, :bank_accounts], notice: "Successfully added a bank account"
    else
      @bank_account = results.bank_account
      render :new
    end
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(
      :bank_name,
      :last_four,
      :balanced_uri,
      :account_type
    )
  end

  def representative_params
    return {} if params[:representative].blank?
    params.require(:representative).permit(
      :name,
      :ein,
      {dob: [:year, :month, :day]},
      :ssn_last4,
      {address: [:line1, :postal_code]}
    )
  end
end
