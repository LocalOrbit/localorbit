class Admin::MarketManagersController < AdminController
  before_action :require_admin_or_market_manager

  def index
    @market = current_user.markets.find(params[:market_id])
  end

  def new
    @market = current_user.markets.find(params[:market_id])
  end

  def create
    @market = current_user.markets.find(params[:market_id])
    email = params.require(:email)
    result = AddMarketManager.perform(market: @market, email: email, inviter: current_user)
    if result.success?
      redirect_to [:admin, @market, :managers], notice: "Sent invitation to #{email}"
    else
      redirect_to [:admin, @market, :managers], alert: "#{email} could not be invited."
    end
  end

  def destroy
    @market = current_user.markets.find(params[:market_id])
    @user = User.find(params[:id])
    @market.managers.delete(@user)
    redirect_to [:admin, @market, :managers]
  end
end
