class Admin::DeliveryToolsController < AdminController
  before_filter :require_selected_market

  def show
    @upcoming_deliveries = current_market.upcoming_deliveries_for_user(current_user).decorate
  end
end
