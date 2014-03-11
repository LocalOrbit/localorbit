class Admin::Financials::OrdersController < AdminController
  def index
    @orders = Order.orders_for_user(current_user)
  end
end
