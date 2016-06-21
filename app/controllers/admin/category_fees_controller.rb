class Admin::CategoryFeesController < AdminController

  def index
    @market = current_user.markets.find(params[:market_id])
    @fees = CategoryFee.joins(:category).where(market_id: params[:market_id]).order('lft')
    respond_to do |format|
      format.html
    end
  end

  def create
    fee = CategoryFee.new(category_fee_params)
    fee.save!
    redirect_to admin_market_category_fees_path
  end

  def new
  end

  def update
  end

  def destroy
    params.require(:id)
    CategoryFee.find(params[:id]).destroy
    redirect_to admin_market_category_fees_path
  end

  private

  def category_fee_params
    params.require(:category_fee).permit(:category_id, :market_id, :fee_pct)
  end
end