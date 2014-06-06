class Admin::PromotionsController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_featured_promotion, only: [:show, :update, :destroy]

  def index
    @promotions = Promotion.promotions_for_user(current_user)
  end

  def new
    fetch_markets_and_products
    @promotion = Promotion.new
  end

  def show
    fetch_markets_and_products
  end

  def create
    @promotion = Promotion.new(promotion_params)
    if @promotion.save
      redirect_to admin_featured_promotions_path, notice: "Successfully created the featured promotion."
    else
      fetch_markets_and_products
      render "new"
    end
  end

  def update
    if @promotion.update(promotion_params)
      redirect_to admin_featured_promotions_path, notice: "Successfully updated the featured promotion."
    else
      fetch_markets_and_products
      render "show"
    end
  end

  def destroy
    @promotion.destroy

    redirect_to admin_featured_promotions_path
  end

  private

  def promotion_params
    params.require(:featured_promotion).permit(:name, :market_id, :title, :product_id)
  end

  def find_featured_promotion
    @promotion = Promotion.find(params[:id])
  end

  def fetch_markets_and_products
    @markets = current_user.markets.order(:name)
    @products = current_user.managed_products.order(:name)
  end
end
