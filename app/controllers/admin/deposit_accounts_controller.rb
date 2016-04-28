class Admin::DepositAccountsController < AdminController
  before_action :load_market_and_set_payment_provider

  def index
    @bank_accounts = @market.bank_accounts.visible.deposit_accounts
  end

  def new
    @bank_account = @market.bank_accounts.build 
  end

  def create
    results = PaymentProvider.add_deposit_account(@payment_provider, 
                                                 type: params[:type], 
                                                 entity: @market, 
                                                 bank_account_params: bank_account_params)
    if results.success?
      redirect_to [:admin, @market, :deposit_accounts], notice: "Successfully added deposit account"
    else
      flash.now[:alert] = "Unable to save deposit account"
      @bank_account = results.bank_account
      render :new
    end
  end

  def destroy
    if bank_account = @market.bank_accounts.find(params[:id])
      bank_account.destroy
      redirect_to [:admin, @entity, :deposit_accounts], notice: "Successfully removed deposit account"
    else
      redirect_to [:admin, @entity, :deposit_accounts]
    end
  end

  private

  def load_market_and_set_payment_provider
    @market = Market.managed_by(current_user).find(params[:market_id])
    @entity = @market
    @payment_provider = @market.payment_provider
  end

  def bank_account_params
    params.require(:bank_account).permit(
      :bank_name,
      :name,
      :last_four,
      :stripe_tok,
      :account_type, # card, checking, savings
      :notes
    )
  end
  
end
