class OrdersController < ApplicationController
  before_action :hide_admin_navigation

  def create
    @order = Order.create_from_cart(order_params, current_cart).decorate
    if @order.persisted?
      current_cart.destroy
      session.delete(:cart_id)
    end
  end

  protected

  def order_params
    params.require(:order).permit(:payment_method, :payment_note)
  end
end
