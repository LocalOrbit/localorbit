class OrdersController < ApplicationController
  before_action :hide_admin_navigation

  def create
    @placed_order = PlaceOrder.perform(order_params: order_params, cart: current_cart)
    @order = @placed_order.order.decorate

    session.delete(:cart_id) if @placed_order.success?
  end

  protected

  def order_params
    params.require(:order).permit(:payment_method, :payment_note)
  end
end
