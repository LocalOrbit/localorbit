class ProductsController < ApplicationController
  before_action :require_selected_market
  before_action :require_market_open
  before_action :require_current_organization
  before_action :require_organization_location
  before_action :require_current_delivery
  before_action :require_cart
  before_action :hide_admin_navigation
  before_action :load_products

  def index
    if current_market.alternative_order_page
      render 'alternative_order_page'
    else
      render 'index'
    end
  end

  def show
    @product = @products_for_sale.products.first || raise(ActiveRecord::RecordNotFound)

    @breadcrumbs = [@product.category]
    while @breadcrumbs.last.parent_id.present?
      @breadcrumbs.push @breadcrumbs.last.parent
    end
    @breadcrumbs.pop
    @breadcrumbs.reverse!
  end

  private

  def load_products
    @products_for_sale = ProductsForSale.new(current_delivery, current_organization, current_cart, request.query_parameters, product_id: params[:id])
  end
end
