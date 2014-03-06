class ProductsController < ApplicationController
  helper_method :current_market

  def index
    products = Product.available_for_market(current_market)
    @categories = products.map {|p| p.category.top_level_category }.uniq

    @products = products.periscope(request.query_parameters).decorate
  end

  def current_market
    current_user.markets.first
  end
end
