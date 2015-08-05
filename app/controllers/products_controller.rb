class ProductsController < ApplicationController
  include ActiveSupport::NumberHelper
  before_action :before_actions, only: [:index, :show]
  before_action :load_sellers, only: [:index, :search]
  skip_before_action :set_intercom_attributes, :masquerade_user!, only: [:search]

  def before_actions
    require_selected_market
    require_market_open
    require_current_organization
    require_organization_location
    require_current_delivery
    require_cart
    hide_admin_navigation
    load_products
    load_sellers
  end

  def index
    if current_market.alternative_order_page
      render 'alternative_order_page'
      return
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

  def search
    search = params[:q].gsub(' ', '+')
    org_filter = params[:organization] || @sellers.pluck(:id)
    if search.length > 3
      matching_and_available_products = current_delivery
        .object
        .delivery_schedule
        .products
        .with_available_inventory(current_delivery.deliver_on)
        .priced_for_market_and_buyer(current_market, current_organization)
        .where(organization_id: org_filter)
        .search_by_text(search)
        .limit(50)
        .includes(:organization, :second_level_category, :prices, :unit)
        .uniq
      render :json => matching_and_available_products.map {|p| search_hash(p)}
    else
      render :json => []
    end
  end

  def render_product_row
    product = Product.find(params[:product_id])
    if product
      render :json => {
        html: render_to_string("_table_row", :locals => {
          product: product.decorate(context: {current_cart: current_cart})
        }, :layout => false)
      }
    end
  end

  private

  def search_hash(product)
    prices = product.prices_for_market_and_organization(current_market, current_organization)
    formatted_prices = prices.map {|price| "#{number_to_currency(price.sale_price)} for #{price.min_quantity}+"}.join(', ')
    {
      :id=> product.id,
      :name=> product.name,
      :second_level_category_name => product.second_level_category.name,
      :seller_name => product.organization.name,
      :pricing => formatted_prices,
      :unit_with_description => product.unit_with_description(:plural)
    }
  end

  def load_sellers
    @sellers ||= current_market.organizations.where(can_sell: true, active: true).order(:name)
  end

  def load_products
    @products_for_sale = ProductsForSale.new(current_delivery, current_organization, current_cart, request.query_parameters, product_id: params[:id])
  end
end
