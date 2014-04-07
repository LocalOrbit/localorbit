class Admin::DeliveryToolsController < AdminController
  def show
    @upcoming_deliveries = current_market.upcoming_deliveries_for_user(current_user).decorate
  end
end
