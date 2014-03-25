class SellersController < ApplicationController
  before_action :require_current_organization
  before_action :require_organization_location
  before_action :require_current_delivery
  before_action :require_cart

  before_action :hide_admin_navigation

  before_action :find_market_sellers
  before_action :hide_admin_navigation

  def index
    @current_seller = @sellers.order("RANDOM()").first.decorate
    @categories = Category.where(depth: 2)
    @product_groups = products_for_seller(@current_seller).group_by{|p| p.category.self_and_ancestors.find_by(depth: 2).id }
  end

  def show
    @current_seller = @sellers.find(params[:id]).decorate
    @categories = Category.where(depth: 2)
    @product_groups = products_for_seller(@current_seller).group_by{|p| p.category.self_and_ancestors.find_by(depth: 2).id }
    render :index
  end

  private

  def products_for_seller(seller)
    Product.available_for_sale(current_market, current_organization).where(organization_id: seller.id).decorate(context: {current_cart: current_cart})
  end

  def find_market_sellers
    @sellers = current_market.organizations.selling
  end
end
