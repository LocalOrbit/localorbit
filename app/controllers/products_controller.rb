class ProductsController < ApplicationController
  before_action :require_shopping_cart_dependencies
  before_action :require_organization_location
  before_action :hide_admin_navigation
  before_action :require_cart

  include CartItems

  def index
    products = Product.available_for_sale(current_market, current_organization)
    # TODO: Optimize this lookup. It just got much more expensive
    @categories = products.unscope(:select).select("DISTINCT (products.top_level_category_id)").map(&:top_level_category)
    @products = products.periscope(request.query_parameters).decorate( context: {current_cart: current_cart})
  end
end
