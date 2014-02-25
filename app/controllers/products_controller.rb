class ProductsController < ApplicationController
  helper_method :current_market

  def index
    @products = Product.available_for_market(current_market).
      periscope(request.query_parameters)
  end

  def current_market
    current_user.markets.first
  end
end
