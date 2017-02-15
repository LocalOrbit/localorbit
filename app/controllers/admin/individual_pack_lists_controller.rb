class Admin::IndividualPackListsController < AdminController
  def show
    #@delivery = Delivery.find(params[:id]).decorate
    dt = params[:deliver_on].to_date
    dte = dt.strftime("%Y-%m-%d")

    if params[:market_id].nil?
      market_id = current_market.id
    else
      market_id = params[:market_id]
    end

    order_items = OrderItem.for_delivery_date_and_user(dte, current_user, market_id)

    #order_items = OrderItem.for_delivery_and_user(@delivery, current_user)
    @pack_lists = OrdersBySellerPresenter.new(order_items)
    #@delivery_notes = DeliveryNote.joins(:order).where(orders: {delivery_id: @delivery.id})
    @delivery_notes = DeliveryNote.joins(:order).where(order: order_items.map(&:order_id))
  end
end
