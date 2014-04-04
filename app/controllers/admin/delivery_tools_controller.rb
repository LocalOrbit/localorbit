class Admin::DeliveryToolsController < AdminController
  def index
    @upcoming_deliveries = if current_user.market_manager? || current_user.admin?
      current_market.deliveries.future.with_orders.order("deliver_on")
    else
      current_market.deliveries.future.
        with_orders_for_organization(current_organization).
        order("deliver_on")
    end
  end
end
