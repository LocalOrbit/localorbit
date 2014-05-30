class Admin::OrdersController < AdminController
  def index
    @search_presenter = OrderSearchPresenter.new(request.query_parameters, current_user)

    @q = Order.orders_for_seller(current_user).search(params[:q])
    @orders = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    @order = SellerOrder.find(current_user, params[:id])
  end

  def update
    order = Order.find(params[:id])
    if order.update(order_params) && StoreOrderFees.perform(order: order)
      redirect_to admin_order_path(order), notice: "Order successfully updated."
    else
      @order = SellerOrder.new(order, current_user)
      render :show
    end
  end

  protected
  def order_params
    params.require(:order).permit(:notes, items_attributes: [
      :id, :quantity_delivered, :delivery_status
      ])
  end

end
