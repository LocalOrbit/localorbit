class OrdersController < ApplicationController
  before_action :require_cart
  before_action :hide_admin_navigation

  def create
    if current_cart.items.empty?
      redirect_to [:products], alert: "Your cart is empty. Please add items to your cart before checking out."
      return
    end

    @placed_order = PlaceOrder.perform(buyer: current_user, order_params: order_params, cart: current_cart)
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
    params.require(:order).permit(:payment_method, :payment_note, :credit_card)
  end
end
