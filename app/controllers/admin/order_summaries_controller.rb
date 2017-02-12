class Admin::OrderSummariesController < AdminController
  def show
    #@delivery = Delivery.find(params[:id]).decorate
    dt = params[:deliver_on].to_date
    dte = dt.strftime("%Y-%m-%d")
    order_items = OrderItem.for_delivery_date_and_user(dte, current_user)
    @summaries = OrdersBySellerPresenter.new(order_items)
    #@delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
    @delivery_notes = DeliveryNote.joins(:order).where(order: order_items.map(&:order_id))

  end
end
