class OrdersController < ApplicationController
  before_action :hide_admin_navigation

  def create
    @placed_order = PlaceOrder.perform(order_params: order_params.merge(current_user: current_user), cart: current_cart)
    @order = @placed_order.order.decorate
    if @placed_order.success?
      session.delete(:cart_id)
    else
      @grouped_items = current_cart.items.for_checkout
      flash.now[:alert] = "Your order could not be completed."
      render "carts/show"
    end
  end

  protected

  def order_params
    params.require(:order).permit(:payment_method, :payment_note, :current_user)
  end
end
