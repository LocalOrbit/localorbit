class OrdersController < ApplicationController
  before_action :hide_admin_navigation

  def create
    @order = Order.create_from_cart(current_cart)
  end
end
