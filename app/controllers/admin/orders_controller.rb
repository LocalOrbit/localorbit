class Admin::OrdersController < AdminController
  def index
    @orders = Order.orders_for_seller(current_user).periscope(request.query_parameters).page(params[:page]).per(params[:per_page])
  end

  def show
    @order = SellerOrder.find(current_user, params[:id])
  end
end
