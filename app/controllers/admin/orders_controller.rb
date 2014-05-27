class Admin::OrdersController < AdminController
  def index
    @orders = Order.orders_for_seller(current_user).periscope(request.query_parameters).page(params[:page]).per(params[:per_page])
  end

  def show
    @order = SellerOrder.find(current_user, params[:id])
  end

  def update
    order = Order.find(params[:id])
    if order.update(order_params) && StoreOrderFees.perform(order: order)
      redirect_to admin_order_path(order)
    else
      @order = SellerOrder.new(order, current_user)
      render :show
    end
  end

  protected
  def order_params
    params.require(:order).permit(items_attributes: [
      :id, :quantity_delivered, :delivery_status
      ])
  end

end
