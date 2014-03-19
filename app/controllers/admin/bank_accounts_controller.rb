class Admin::BankAccountsController < AdminController
  before_filter :find_organization

  def index
    @bank_accounts = @organization.bank_accounts
  end

  def new
    @bank_account = @organization.bank_accounts.build
  end

  def create
    results = AddBankAccountToOrganization.perform(organization: @organization, bank_account_params: bank_account_params, representative_params: representative_params)

    if results.success?
      redirect_to admin_organization_bank_accounts_path(@organization)
    else
      @bank_account = results.bank_account
      render :new
    end
  end

  private

  def find_organization
    @organization = current_user.managed_organizations.find(params[:organization_id])
  end

  def bank_account_params
    params.require(:bank_account).permit(
      :bank_name,
      :last_four,
      :balanced_uri,
      :account_type
    )
  end

  def representative_params
    params.require(:representative).permit(
      :name,
      :ein,
      {dob: [:year, :month, :day]},
      :ssn_last4,
      {address: [:line1, :postal_code]}
    )
  end
end

