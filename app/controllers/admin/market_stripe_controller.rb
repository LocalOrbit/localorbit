class Admin::MarketStripeController < AdminController
  before_action :require_admin_or_market_manager
  before_action :find_market

  def show
  end
end