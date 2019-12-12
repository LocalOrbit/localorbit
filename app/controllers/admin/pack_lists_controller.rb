class Admin::PackListsController < AdminController
  before_action :require_admin_or_market_manager

  def show
    dt = params[:deliver_on].to_date

    if params[:market_id].nil?
      market_id = current_market.id
    else
      market_id = params[:market_id]
    end

    if current_user.buyer_only? || current_user.market_manager?
      @orders = Order.joins(:items, :delivery)
                    .where(order_items: {delivery_status: "pending"})
                    .where(orders: {market_id: market_id})
                    .order(:order_number).group("deliveries.buyer_deliver_on, orders.id")
                    .where(deliveries: {buyer_deliver_on: dt.beginning_of_day..dt.end_of_day})
                    .select("deliveries.buyer_deliver_on, orders.*")
    else
      @orders = Order.joins(:items, :delivery)
                    .where(order_items: {delivery_status: "pending"})
                    .where(orders: {market_id: market_id})
                    .order(:order_number).group("deliveries.deliver_on, orders.id")
                    .where(deliveries: {deliver_on: dt.beginning_of_day..dt.end_of_day})
                    .select("deliveries.deliver_on, orders.*")
    end

    @delivery_notes = DeliveryNote.joins(:order).where(order: @orders.map(&:id))
  end
end
