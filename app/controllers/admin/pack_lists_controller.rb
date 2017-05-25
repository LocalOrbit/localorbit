class Admin::PackListsController < AdminController
  before_action :require_admin_or_market_manager

  def show
    #@delivery = Delivery.find(params[:id]).decorate
    dt = params[:deliver_on].to_date
    dte = dt.strftime("%Y-%m-%d")

    if params[:market_id].nil?
      market_id = current_market.id
    else
      market_id = params[:market_id]
    end

    #market_id = Market.managed_by(current_user).pluck(:id)

    if current_user.buyer_only? || current_user.market_manager?
      @orders = Order.joins(:items, :delivery)
                    .where(order_items: {delivery_status: "pending"})
                    .where(orders: {market_id: market_id})
                    .order(:order_number).group("deliveries.buyer_deliver_on, orders.id")
                    .where("DATE(deliveries.buyer_deliver_on) = '#{dte}'")
                    .select("deliveries.buyer_deliver_on, orders.*")
    else
      @orders = Order.joins(:items, :delivery)
                    .where(order_items: {delivery_status: "pending"})
                    .where(orders: {market_id: market_id})
                    .order(:order_number).group("deliveries.deliver_on, orders.id")
                    .where("DATE(deliveries.deliver_on) = '#{dte}'")
                    .select("deliveries.deliver_on, orders.*")
    end

    #@orders = @delivery.orders.joins(:items).where(order_items: {delivery_status: "pending"}).order(:order_number).group("orders.id")
    #@delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
    @delivery_notes = DeliveryNote.joins(:order).where(order: @orders.map(&:id))
  end
end
