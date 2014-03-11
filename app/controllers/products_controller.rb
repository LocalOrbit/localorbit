class ProductsController < ApplicationController
  helper_method :current_market

  def index
    products = Product.available_for_sale(current_market, current_organization)
    # TODO: Optimize this lookup. It just got much more expensive
    @categories = products.unscope(:select).select("DISTINCT (products.top_level_category_id)").map(&:top_level_category)

    @products = products.periscope(request.query_parameters).decorate
  end
end
