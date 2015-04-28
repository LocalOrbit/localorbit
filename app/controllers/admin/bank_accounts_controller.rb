class Admin::BankAccountsController < AdminController
  include BankAccountEntity
  before_action :set_balanced_flag

  def index
    @bank_accounts = @entity.bank_accounts.visible
  end

  def new
    @bank_account = @entity.bank_accounts.build
  end

  def create
    results = if params[:type] == "card"
      AddCreditCardToEntity.perform(entity: @entity, bank_account_params: bank_account_params, representative_params: representative_params)
    else
      AddBankAccountToEntity.perform(entity: @entity, bank_account_params: bank_account_params, representative_params: representative_params)
    end

    if results.success?
      redirect_to [:admin, @entity, :bank_accounts], notice: "Successfully added a payment method"
    else
      flash.now[:alert] = "Unable to save payment method"
      @bank_account = results.bank_account
      render :new
    end
  end

  def destroy
    @entity.bank_accounts.find(params[:id]).destroy
    redirect_to [:admin, @entity, :bank_accounts], notice: "Successfully removed payment method"
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(
      :bank_name,
      :name,
      :last_four,
      :balanced_uri,
      :account_type,
      :expiration_month,
      :expiration_year,
      :notes
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

  def set_payment_provider
    @payment_provider = 'balanced'
  end
end
