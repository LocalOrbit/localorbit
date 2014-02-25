class ProductsController < ApplicationController
  def index
    @products = Product.available_for_market(current_market)
  end

  private

  def current_market
    current_user.markets.first
  end
end
