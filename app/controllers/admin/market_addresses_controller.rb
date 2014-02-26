class Admin::MarketAddressesController < AdminController
  before_action :require_admin_or_market_manager, except: [:new, :create]
  
  def index
    @addresses = current_market.addresses 
  end

  def new
    @address = MarketAddress.new(market: current_market)
  end

  def create
    @address = MarketAddress.create(market_address_params)
    if @address.errors.any?
      render :new
    else
      redirect_to admin_market_addresses_path(current_market)
    end
  end

  def edit
    current_market
    @address = MarketAddress.where(id: params[:id]).first
  end

  def update
    @address = MarketAddress.where(id: params[:id]).first
    if @address.update_attributes(market_address_params)
      redirect_to admin_market_addresses_path(current_market)
    else
      render :edit
    end

  end

  private

  def market_address_params
    params.require('market_address').permit(
      :name,
      :address,
      :city,
      :state,
      :zip,
    ).merge(market_id: params[:market_id])
  end
  
  def current_market
    @market = Market.where(id: params[:market_id]).first
  end
end
