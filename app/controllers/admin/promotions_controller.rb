class Admin::PromotionsController < AdminController
  include StickyFilters

  before_action :require_admin_or_market_manager
  before_action :find_featured_promotion, only: [:show, :update, :destroy, :activate, :deactivate]
  before_action :find_sticky_params, only: :index

  def index
    base_scope = Promotion.promotions_for_user(current_user)

    @markets = base_scope.map(&:market).uniq

    @q = base_scope.search(@query_params["q"])
    @promotions = @q.result.page(params[:page]).per(@query_params[:per_page])
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
      redirect_to admin_promotions_path, notice: "Successfully created the featured promotion."
    else
      fetch_markets_and_products
      render "new"
    end
  end

  def update
    if @promotion.update(promotion_params)
      redirect_to admin_promotions_path, notice: "Successfully updated the featured promotion."
    else
      fetch_markets_and_products
      render "show"
    end
  end

  def destroy
    @promotion.destroy

    redirect_to admin_promotions_path
  end

  def activate
    @promotion.market.promotions.update_all(active: false)
    @promotion.update(active: true)

    redirect_to admin_promotions_path
  end

  def deactivate
    @promotion.update(active: false)

    redirect_to admin_promotions_path
  end

  private

  def promotion_params
    params.require(:promotion).permit(:name, :market_id, :title, :product_id, :body, :image)
  end

  def find_featured_promotion
    @promotion = Promotion.find(params[:id])
  end

  def fetch_markets_and_products
    @markets = current_user.markets.order(:name)
    @products = current_user.managed_products.order("organizations.name, general_products.name")
  end
end
