class ProductsController < ApplicationController
  before_action :require_current_organization
  before_action :require_organization_location
  before_action :require_current_delivery
  before_action :require_cart
  before_action :hide_admin_navigation

  def index
    @categories = Category.where(depth: 2)
    @product_groups = products.periscope(request.query_parameters).decorate( context: {current_cart: current_cart}).group_by{|p| p.category.self_and_ancestors.find_by(depth: 2) }
    @filter_categories = Category.where(id: products.pluck(:top_level_category_id).uniq)
    @filter_organizations = current_market.organizations.selling.where(id: products.pluck(:organization_id).uniq)
  end

  def show
    @product = products.find(params[:id]).decorate(context: {current_cart: current_cart})

    cat = @product.category
    @breadcrumbs = [cat]
    while cat.parent_id.present?
      @breadcrumbs.push cat.parent
      cat = cat.parent
    end
    @breadcrumbs.pop
    @breadcrumbs.reverse!
  end

  private

  def products
    current_delivery.delivery_schedule.products.available_for_sale(current_market, current_organization)
  end
end
