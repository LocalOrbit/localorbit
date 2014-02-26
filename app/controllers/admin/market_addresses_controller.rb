class Admin::MarketAddressesController < AdminController
  before_action :require_admin_or_market_manager, except: [:new, :create]
  
  def index
    @addresses = current_market.addresses 
  end

  private

  def current_market
    Market.where(id: params[:market_id]).first
  end
end
