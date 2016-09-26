class Admin::MarketCrossSellsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_market

  def show
    @cross_selling_markets = current_user.markets.where(allow_cross_sell: true).where.not(id: @market.id).order(:name)
  end

  # Clumsy as it is, this is the most natural place to address orphaned
  # cross selling lists, even if it does bind the classes together
  def update
    ids = params[:market].try(:[], :cross_sell_ids) || []

    # Get removed markets...
    removed = @market.cross_sells.map{|m| m.id.to_s} - ids

    # ...and revoke any lists published by @market subscribed to by removed markets
    unless removed.blank?
      @market.cross_selling_lists.each do |list|
        list.children.each do |child|
          child.revoke! if removed.include?(child.entity_id.to_s)
        end
      end
    end

    @market.cross_sell_ids = ids

    redirect_to admin_market_cross_sell_path(@market), notice: "Market Updated Successfully"
  end

  protected

  def find_market
    @market = current_user.markets.find(params[:market_id])
  end
end
