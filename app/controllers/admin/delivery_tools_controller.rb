class Admin::DeliveryToolsController < AdminController
  before_action :require_selected_market

  def show
    if current_user.buyer_only? || current_user.market_manager?
      o_scope = "buyer_deliver_on"
    else
      o_scope = "deliver_on"
    end
    @upcoming_deliveries = current_user.markets.map{|market| market.upcoming_deliveries_for_user(current_user).order(o_scope).decorate}.flatten
  end
end
