class Admin::PackListsController < AdminController
  before_action :require_admin_or_market_manager

  def show
    #@delivery = Delivery.find(params[:id]).decorate
    dt = params[:deliver_on].to_date
    dte = dt.strftime("%Y-%m-%d")
    @orders = Order.joins(:items, :delivery)
                  .where(order_items: {delivery_status: "pending"})
                  .order(:order_number).group("deliveries.buyer_deliver_on, orders.id")
                  .where("DATE(deliveries.deliver_on) = '#{dte}'")
                  .select("deliveries.buyer_deliver_on, orders.*")

    #@orders = @delivery.orders.joins(:items).where(order_items: {delivery_status: "pending"}).order(:order_number).group("orders.id")
    #@delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
    @delivery_notes = DeliveryNote.joins(:order).where(order: @orders.map(&:id))
  end
end
