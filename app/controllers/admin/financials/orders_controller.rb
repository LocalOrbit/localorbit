class Admin::Financials::OrdersController < AdminController
  def index
    @orders = Order.orders_for_seller(current_user)
  end

  def show
    @order = SellerOrder.find(current_user, params[:id])
  end
end
