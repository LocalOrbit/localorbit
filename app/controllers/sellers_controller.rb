class SellersController < ApplicationController
  before_action :require_current_organization
  before_action :require_organization_location
  before_action :require_current_delivery
  before_action :require_cart

  before_action :hide_admin_navigation

  before_action :find_market_sellers
  before_action :hide_admin_navigation

  def index
    if @sellers.empty?
      @empty_message = "#{current_market.name} has no sellers at this time."
    else
      @current_seller = @sellers.order("RANDOM()").first.decorate
      load_products(@current_seller)
    end
    render :show
  end

  def show
    @current_seller = current_market.organizations.active.selling.find(params[:id]).decorate
    load_products(@current_seller)
  end

  private

  def load_products(seller)
    @products_for_sale = ProductsForSale.new(current_delivery, current_organization, current_cart, request.query_parameters, seller: seller)
  end

  def products_for_seller(seller)
    current_delivery.products_available_for_sale(current_organization).
      where(organization_id: seller.id).
      includes(:unit, :category).
      decorate(context: {current_cart: current_cart})
  end

  def find_market_sellers
    organization_ids = current_market.organizations.visible.active.selling.collect(&:id) | current_market.cross_selling_organizations.collect(&:id)

    @sellers = Organization.where(id: organization_ids)
  end
end
