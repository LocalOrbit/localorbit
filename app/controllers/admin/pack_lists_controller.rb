class Admin::PackListsController < AdminController
  before_action :require_admin_or_market_manager

  def show
    @delivery = Delivery.find(params[:id]).decorate
    @orders = @delivery.orders.joins(:items).where(order_items: {delivery_status: "pending"}).order(:order_number).group("orders.id")
    @delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
  end
end
