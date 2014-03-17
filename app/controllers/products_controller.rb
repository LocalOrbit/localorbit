class ProductsController < ApplicationController
  before_action :require_shopping_cart_dependencies
  before_action :hide_admin_navigation
  before_action :load_cart_items

  def index
    products = Product.available_for_sale(current_market, current_organization)
    # TODO: Optimize this lookup. It just got much more expensive
    @categories = products.unscope(:select).select("DISTINCT (products.top_level_category_id)").map(&:top_level_category)
    @products = products.periscope(request.query_parameters).decorate( context: {current_cart: current_cart})
  end

  private


  def require_shopping_cart_dependencies
    if current_organization.nil?
      redirect_to [:new, :sessions, :organization]
    elsif current_delivery.nil?
      redirect_to [:new, :sessions, :delivery]
    end
  end

  # The CartModel JavaScript expects items in the format
  #  { item_id: item_object }
  #
  # This could be simplified on the server side, if the CartModel
  # class stored items as an array, and used a library like underscore
  # to find the items.
  def load_cart_items
    @cart_items = {}

    current_cart.items.each do |item|
      @cart_items[item.id.to_s] = item
    end
  end
end
