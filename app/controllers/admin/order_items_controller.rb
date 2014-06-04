module Admin
  class OrderItemsController < AdminController
    def index
      @order_items = OrderItem.for_user(current_user).joins(:order).order("orders.placed_at DESC, name")
      respond_to do |format|
        format.html { @order_items = @order_items.page(params[:page]).per(params[:per_page]) }
        format.csv { @filename = "orders.csv"}
      end
    end

    def set_status
      UpdateOrderItemsStatus.perform(user: current_user, order_item_ids: params[:order_item_ids], delivery_status: params[:delivery_status])
      redirect_to action: :index
    end
  end
end
