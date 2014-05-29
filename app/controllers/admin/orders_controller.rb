class Admin::OrdersController < AdminController
  before_filter :require_admin_or_market_manager, only: :update

  def index
    @search_presenter = OrderSearchPresenter.new(request.query_parameters, current_user)

    @q = Order.orders_for_seller(current_user).search(params[:q])
    @q.sorts = "placed_at desc" if @q.sorts.empty?
    @orders = @q.result.page(params[:page]).per(params[:per_page])
  end

  def show
    @order = SellerOrder.find(current_user, params[:id])
  end

  def update
    order = Order.find(params[:id])
    updates = UpdateOrder.perform(order: order, order_params: order_params)
    if updates.success?
      redirect_to admin_order_path(order), notice: "Order successfully updated."
    else
      order.errors.add(:payment_processor, "failed to update your payment") if updates.context[:status] == 'failed'
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
