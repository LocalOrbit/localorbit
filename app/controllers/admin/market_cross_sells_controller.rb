class Admin::MarketCrossSellsController < AdminController
  before_filter :require_admin_or_market_manager
  before_filter :find_market

  def show
    @cross_selling_markets = Market.where(allow_cross_sell: true).where.not(id: @market.id).order(:name)
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
