class Admin::DepositAccountsController < AdminController
  before_action :load_market_and_set_payment_provider

  def index
    @bank_accounts = [] #@market.bank_accounts.visible
  end

  def new
    @bank_account = @market.bank_accounts.build #TODO 
  end

  def create
    redirect_to [:admin, @market, :bank_accounts], notice: "TODO: add payment method"
    # results = PaymentProvider.add_payment_method(@payment_provider, 
    #                                              type: params[:type], 
    #                                              entity: @entity, 
    #                                              bank_account_params: bank_account_params,
    #                                              representative_params: representative_params)
    #
    # if results.success?
    #   redirect_to [:admin, @entity, :bank_accounts], notice: "Successfully added a payment method"
    # else
    #   flash.now[:alert] = "Unable to save payment method"
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
