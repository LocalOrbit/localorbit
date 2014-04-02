class OrdersController < ApplicationController
  before_action :hide_admin_navigation

  def create
    @placed_order = PlaceOrder.perform(order_params: order_params, cart: current_cart)
    @order = @placed_order.order.decorate
    if @placed_order.success?
      session.delete(:cart_id)
    else
      redirect_to [current_cart], alert: @order.errors.full_messages.join(". ")
    end
  end

  protected

  def order_params
    params.require(:order).permit(:payment_method, :payment_note)
  end
end
