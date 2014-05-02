class Admin::CrossSellsController < AdminController
  before_filter :find_market

  def show
    @cross_selling_markets = Market.where(allow_cross_sell: true).where.not(id: @market.id).order(:name)
  end

  def update
    @market.cross_sell_ids = cross_sell_params[:cross_sell_ids]

    redirect_to admin_market_cross_sell_path(@market), notice: "Market Updated Successfully"
  end

  protected

  def cross_sell_params
    params.require(:market).permit(cross_sell_ids: [])
  end

  def find_market
    @market = current_user.markets.find(params[:market_id])
  end
end
