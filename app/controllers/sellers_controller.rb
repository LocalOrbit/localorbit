class SellersController < ApplicationController
  before_filter :find_market_sellers

  def index
    @current_seller = @sellers.order("RANDOM()").first.decorate
  end

  def show
    @current_seller = @sellers.find(params[:id]).decorate
    render :index
  end

  private

  def find_market_sellers
    @sellers = current_market.organizations.selling
  end
end
