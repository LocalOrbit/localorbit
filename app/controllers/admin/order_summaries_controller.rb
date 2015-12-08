class Admin::OrderSummariesController < AdminController
  def show
    @delivery = Delivery.find(params[:id]).decorate
    order_items = OrderItem.for_delivery_and_user(@delivery, current_user)
    @summaries = OrdersBySellerPresenter.new(order_items)
    @delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
  end
end
