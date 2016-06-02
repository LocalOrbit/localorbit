class Admin::MarketCrossSellsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_market

  # KXM I expect the meat of both this and OrganizationCrossSellsController to be substantially similar - perhaps an opportunity to create a parent controller for both?
  def show
    @cross_selling_markets = current_user.markets.where(allow_cross_sell: true).where.not(id: @market.id).order(:name)
  end

  def new
  end

  def create
  end

  # KXM This controller (Admin::MarketCrossSellsController) will need to be beefed up.  For the time being I'll replace the update function
  def update
    # KXM Original code to HERE
    # ids = params[:market].try(:[], :cross_sell_ids) || []
    # @market.cross_sell_ids = ids
    # HERE

    @market.toggle!(:market_enabled_cross_sell)

    notice = @market.market_enabled_cross_sell? ? "Cross selling is now active" : "Cross selling is now inactive"

    # KXM This is also original
    redirect_to admin_market_cross_sell_path(@market), notice: notice
  end

  protected

  def find_market
    @market = current_user.markets.find(params[:market_id])
  end
end
