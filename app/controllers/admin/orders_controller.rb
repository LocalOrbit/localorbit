class Admin::OrdersController < AdminController
  include StickyFilters

  before_action :find_sticky_params, only: :index

  def index
    @query_params["placed_at_date_gteq"] ||= 7.days.ago.to_date.to_s
    @query_params["placed_at_date_lteq"] ||= Date.today.to_s
    @search_presenter = OrderSearchPresenter.new(@query_params, current_user, "placed_at")
    @q, @totals = search_and_calculate_totals(@search_presenter)

    @orders = @q.result(distinct: true).page(params[:page]).per(@query_params[:per_page])
  end

  def search_and_calculate_totals(search)
    results = Order.includes(:organization, :items, :delivery).orders_for_seller(current_user).search(search.query)
    results.sorts = "placed_at desc" if results.sorts.empty?

    if !current_user.admin?
      order_ids = results.result.map(&:id)
      order_items = OrderItem.includes(:product, :order).joins(:product).where(:order_id => order_ids, "products.organization_id" => current_user.managed_organization_ids_including_deleted)
      totals = OrderTotals.new(order_items)
    else
      totals = OrderTotals.new(OrderItem.where("1 = 0"))
    end
    [results, totals]
  end

  def show
    order = Order.orders_for_seller(current_user).find(params[:id])
    if current_user.organization_ids.include?(order.organization_id) || current_user.can_manage_organization?(order.organization)
      @order = BuyerOrder.new(order)
    else
      @order = SellerOrder.new(order, current_user)
    end
    setup_deliveries(@order)
    track_event EventTracker::ViewedOrder.name, order: { url: admin_order_url(order.id), value: @order.order_number }
  end

  def update
    order = Order.find(params[:id])
    setup_deliveries(order)

    if params["items_to_add"]
      return unless perform_add_items(order)
    elsif params[:commit] == "Add Items"
      show_add_items_form(order)
      return
    elsif params[:commit] == "Change Delivery"
      update_delivery(order)
      return
    end

    # TODO: Change an order items delivery status to 'removed' or something rather then deleting them
    perform_order_update(order, order_params)
  end

  protected

  def order_params
    params[:order].delete(:delivery_id) # Remove the parameter so it doesn't conflict
    params.require(:order).permit(:notes, items_attributes: [
      :id, :quantity, :quantity_delivered, :delivery_status, :_destroy
    ])
  end

  def update_delivery(order)
    order = Order.find(params[:id])

    updates = UpdateOrderDelivery.perform(user: current_user, order: order, delivery_id: params.require(:order)[:delivery_id])
    if updates.success?
      redirect_to admin_order_path(order), notice: "Delivery successfully updated."
    else
      redirect_to admin_order_path(order), alert: "This order's delivery cannot be changed at this time. Our support team has been notified and will update you with more information."
    end
  end

  def items_to_add
    items = params.require(:items_to_add)
    items.select {|i| i[:quantity].to_i > 0 }
  end

  def setup_add_items_form(order)
    @show_add_items_form = true
    @order = SellerOrder.new(order, current_user)
    user_order_context = UserOrderContext.build(user: current_user, order: @order)
    if FeatureAccess.add_order_items?(user_order_context: user_order_context)
      if user_order_context.is_admin or user_order_context.is_market_manager
        # If admin or MM, do NOT limit products to seller org:
        @products_for_sale = ProductsForSale.new(order.delivery, order.organization, Cart.new(market: order.market))
      else
        @products_for_sale = ProductsForSale.new(order.delivery, order.organization, Cart.new(market: order.market), {}, {seller: user_order_context.seller_organization })
      end

    else
      @products_for_sale = ProductsForSale.new(order.delivery, order.organization, Cart.new(market: order.market))
    end
  end

  # Builds a list of deliveries for potential changes
  # Some from the past, some from future, and the order's actual one.
  def setup_deliveries(order)
    recent_deliveries = order.market.deliveries.recent
    future_deliveries = order.market.deliveries.future.active

    @deliveries = recent_deliveries | future_deliveries | [order.delivery]
  end

  def perform_order_update(order, params)
    updates = UpdateOrder.perform(payment_provider: order.payment_provider, order: order, order_params: params)
    if updates.success?
      came_from_admin = request.referer.include?("/admin/")
      next_url = if order.reload.items.any?
        came_from_admin ? admin_order_path(order) : order_path(order)
      else
        order.soft_delete
        came_from_admin ? admin_orders_path(order) : orders_path(order)
      end
      redirect_to next_url, notice: "Order successfully updated."
    else
      order = updates.context[:order]
      order.errors.add(:payment_processor, "failed to update your payment") if updates.context[:status] == "failed"
      @order = SellerOrder.new(order, current_user)
      render :show
    end
  end

  def perform_add_items(order)
    result = UpdateOrderWithNewItems.perform(payment_provider: order.payment_provider, order: order, item_hashes: items_to_add)
    if !result.success?
      setup_add_items_form(order)
      order.errors[:base] << "Failed to add items to this order."
      render :show
      return false
    end
    true
  end

  def show_add_items_form(order)
    setup_add_items_form(order)
    flash.now[:notice] = "Add items below."
    render :show
  end
end
