class Admin::DeliveryToolsController < AdminController
  before_action :require_selected_market

  def show
    if current_user.buyer_only? || current_user.market_manager?
      o_scope = "delivery_schedules.market_id, buyer_deliver_on"
    else
      o_scope = "delivery_schedules.market_id, deliver_on"
    end
    @upcoming_deliveries = current_user.markets.map{|market| market.upcoming_deliveries_for_user(current_user).group(o_scope).order(o_scope).decorate}.flatten
  end
end
