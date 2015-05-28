class Admin::DepositAccountsController < AdminController
  before_action :load_market_and_set_payment_provider

  def index
    # TODO: 
    @bank_accounts = [] # @market.bank_accounts.visible
  end

  def new
    @bank_account = @market.bank_accounts.build #TODO something more abstract?
  end

  def create
    redirect_to [:admin, @market, :deposit_accounts], notice: "TODO: add payment method"
    # TODO:
    # results = PaymentProvider.add_deposit_account(@payment_provider, 
    #                                              type: params[:type], 
    #                                              entity: @market, 
    #                                              bank_account_params: bank_account_params)
    #
    # if results.success?
    #   redirect_to [:admin, @market, :deposit_accounts], notice: "Successfully added deposit account"
    # else
    #   flash.now[:alert] = "Unable to save deposit account"
    #   @bank_account = results.bank_account
    #   render :new
    # end
  end

  def destroy
    # @entity.bank_accounts.find(params[:id]).destroy
    # redirect_to [:admin, @entity, :bank_accounts], notice: "Successfully removed payment method"
    redirect_to [:admin, @market, :bank_accounts], notice: "TODO: remove deposit account"
  end

  private

  def load_market_and_set_payment_provider
    @market = Market.find(params[:market_id])
    @entity = @market
    @payment_provider = @market.payment_provider

    if PaymentProvider.is_balanced?(@payment_provider)
      redirect_to admin_market_path(id:@market.id)
    end
  end

  def bank_account_params
    params.require(:bank_account).permit(
      :bank_name,
      :name,
      :last_four,
      :stripe_tok,
      :account_type,
      :notes
    )
  end

end
