class Admin::OrdersController < AdminController
  def index
    @search_presenter = OrderSearchPresenter.new(request.query_parameters, current_user)

    @q = Order.orders_for_seller(current_user).search(params[:q])
    @q.sorts = "placed_at asc" if @q.sorts.empty?
    @orders = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    @order = SellerOrder.find(current_user, params[:id])
  end

  def update
    order = Order.find(params[:id])

    # TODO: Change an order items delivery status to 'removed' or something rather then deleting them
    updates = UpdateOrder.perform(order: order, order_params: order_params)
    if updates.success?
      if order.reload.items.any?
        redirect_to admin_order_path(order), notice: "Order successfully updated."
      else
        order.soft_delete
        redirect_to admin_orders_path, notice: "Order successfully updated"
      end
    else
      order = updates.context[:order]
      order.errors.add(:payment_processor, "failed to update your payment") if updates.context[:status] == 'failed'
      @order = SellerOrder.new(order, current_user)
      render :show
    end
  end

  protected
  def order_params
    params.require(:order).permit(:notes, items_attributes: [
      :id, :quantity_delivered, :delivery_status, :_destroy
      ])
  end

end
