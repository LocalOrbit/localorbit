class Admin::MarketCrossSellsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_market

  def show
    @cross_selling_markets = current_user.markets.where(allow_cross_sell: true).where.not(id: @market.id).order(:name)
  end

  def update
    ids = params[:market].try(:[], :cross_sell_ids) || []
    @market.cross_sell_ids = ids

    redirect_to admin_market_cross_sell_path(@market), notice: "Market Updated Successfully"
  end

  protected

  def find_market
    @market = current_user.markets.find(params[:market_id])
  end
end
