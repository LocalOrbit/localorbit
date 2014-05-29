class Admin::OrdersController < AdminController
  def index
    query = request.query_parameters[:q] || {}
    @selected_market_id = query[:market_id_eq].to_s
    @selected_organization_id = query[:organization_id_eq].to_s

    @selling_markets = current_user.managed_markets.order(:name)
    @buyer_organizations = Order.orders_for_seller(current_user).joins(:organization).map(&:organization).uniq

    @q = Order.search(params[:q])
    @orders = @q.result.orders_for_seller(current_user).page(params[:page]).per(params[:per_page])
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
