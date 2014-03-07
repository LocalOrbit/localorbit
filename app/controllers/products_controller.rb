class ProductsController < ApplicationController
  before_action :require_current_organization
  before_action :require_current_delivery_schedule

  def index
    products = Product.available_for_sale(current_market, current_organization)
    # TODO: Optimize this lookup. It just got much more expensive
    @categories = products.unscope(:select).select("DISTINCT (products.top_level_category_id)").map(&:top_level_category)

    @products = products.periscope(request.query_parameters).decorate
  end

  def select_organization
  end

  def select_delivery_schedule
  end

  private

  def require_current_organization
    orgs = current_user.managed_organizations

    if orgs.count > 1
      unless session[:current_organization_id].present?
        redirect_to [:new, :sessions, :organization]
      end
    else
      session[:current_organization_id] = orgs.first.id
    end
  end

  def require_current_delivery_schedule
    unless session[:current_delivery_schedule].present?
      redirect_to [:new, :sessions, :delivery_schedule]
    end
  end
end
