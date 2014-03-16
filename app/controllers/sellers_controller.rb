class SellersController < ApplicationController
  before_action :find_market_sellers
  before_action :hide_admin_navigation

  def index
    @current_seller = @sellers.order("RANDOM()").first.decorate
    @products = Product.available_for_sale(current_market, current_organization).where(organization_id: @current_seller.id).decorate
  end

  def show
    @current_seller = @sellers.find(params[:id]).decorate
    @products = Product.available_for_sale(current_market, current_organization).where(organization_id: @current_seller.id).decorate
    render :index
  end

  private

  def find_market_sellers
    @sellers = current_market.organizations.selling
  end
end
