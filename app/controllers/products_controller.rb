class ProductsController < ApplicationController
  before_action :require_shopping_cart_dependencies

  def index
    products = Product.available_for_sale(current_market, current_organization)
    # TODO: Optimize this lookup. It just got much more expensive
    @categories = products.unscope(:select).select("DISTINCT (products.top_level_category_id)").map(&:top_level_category)

    @products = products.periscope(request.query_parameters).decorate
  end

  private


  def require_shopping_cart_dependencies
    # Before shopping for a product, the session needs the following
    # 1) current_user
    # 2) current_market
    # 3) current_organization_id
    # 4) current_delivery_id
    # 5) current_location_id
    # 6) a shopping cart

    redirect_to [:new, :user, :session] if current_user.nil?
    #redirect_to [:new, :market, :session] if current_market.nil?
    redirect_to [:new, :sessions, :organization] if current_organization.nil?
    redirect_to [:new, :sessions, :delivery] if current_delivery.nil?
  end
end
