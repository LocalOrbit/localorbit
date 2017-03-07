class Admin::OrdersController < AdminController
  include StickyFilters

  before_action :find_sticky_params, only: :index
  before_action :load_qb_session

  def index
    if params["clear"]
      redirect_to url_for(params.except(:clear))
    else
      #@query_params["placed_at_date_gteq"] ||= 7.days.ago.to_date.to_s
      #@query_params["placed_at_date_lteq"] ||= Date.today.to_s
      @search_presenter = OrderSearchPresenter.new(@query_params, current_user, :placed_at)
      @q, @totals = search_and_calculate_totals(@search_presenter)

      @orders = @q.result(distinct: true)

      respond_to do |format|
        format.html do
          @orders = @orders.page(params[:page]).per(@query_params[:per_page])
        end
        format.csv do
          @order_items = find_order_items(@orders.map(&:id))
          @abort_mission = @order_items.count > 2999
          if ENV["USE_UPLOAD_QUEUE"] == "true"
            Delayed::Job.enqueue ::CSVExport::CSVOrderExportJob.new(current_user, @order_items.map(&:id))
            flash[:notice] = "Please check your email for export results."
            redirect_to admin_orders_path
          else
            @filename = "orders.csv"
          end
        end
      end
    end
  end

  def search_and_calculate_totals(search)
    results = Order.includes(:market, :organization, :items, :delivery).orders_for_seller(current_user).search(search.query)
    results.sorts = "placed_at desc" if results.sorts.empty?

    if !current_user.admin? && (current_user.market_manager? || current_user.buyer_only?)
      order_ids = results.result.map(&:id)
      order_items = find_order_items(order_ids)
      totals = OrderTotals.new(order_items)
    elsif current_user.seller?
      order_ids = results.result.map(&:id)
      order_items = Orders::SellerItems.items_for_seller(order_ids, current_user)
      totals = OrderTotals.new(order_items)
    else
      totals = OrderTotals.new(OrderItem.where("1 = 0"))
    end
    [results, totals]
  end

  def create
    case params["order_batch_action"]
      when "export"
        params["order_id"].each do |o|
          order = Order.find(o)
          if order.delivery_status_for_user(current_user) == 'delivered' && order.qb_ref_id.nil?
            if order.order_type == "purchase"
              export_bill(order, true)
            else
              export_invoice(order, true)
            end
          end
        end
        redirect_to admin_orders_path, notice: 'Orders Processed.'

      when "unclose"
        params["order_id"].each do |o|
          order = Order.find(o)
          if order.delivery_status_for_user(current_user) == 'exported' && !order.qb_ref_id.nil?
            unclose_order(order, true)
          end
        end
        redirect_to admin_orders_path, notice: 'Orders Processed.'

      when nil, ""
        redirect_to admin_orders_path, alert: 'No action provided.'

    else
      redirect_to admin_orders_path, alert: "Unsupported action: '#{params[:order_batch_action]}'"

    end
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
    merge = nil

    if params["items_to_add"]
      return unless perform_add_items(order)
    elsif params[:commit] == "Add Items"
      show_add_items_form(order)
      return
    elsif params[:commit] == "Change Delivery"
      update_delivery(order)
      return
    elsif params[:commit] == "Merge"
      dest_order = Order.orders_for_seller(current_user).find_by(id: params[:dest_order]) || Order.orders_for_seller(current_user).find_by(order_number: params[:dest_order])
      merge_order(order, dest_order)
      merge = true
      return
    elsif params[:commit] == "Duplicate Order"
      duplicate_order(order)
      return
    elsif params[:commit] == "Export Invoice"
      export_invoice(order)
      return
    elsif params[:commit] == "Export Bill"
      export_bill(order)
      return
    elsif params[:commit] == "Unclose Order"
      unclose_order(order)
      return
    elsif params["order"][:delivery_clear] == "true"
      remove_delivery_fee(order)
      return
    elsif params["order"][:credit_clear] == "true"
      remove_credit(order)
      return
    # elsif params[:commit] == "Undo Mark Delivered"
    #   undo_delivery(order) # But this is not where Mark Delivered goes,sooooo
    end

    # TODO: Change an order items delivery status to 'removed' or something rather then deleting them
    perform_order_update(order, order_params, merge)
  end

  def duplicate_order(order)
    result = DuplicateOrder.perform(user: current_user, order: order)
    if result.success?
      session[:cart_id] = result.cart_id
      session[:current_organization_id] = result.current_organization_id
      session[:current_delivery_id] = result.current_delivery_id
      session[:current_delivery_day] = result.current_delivery_day
      redirect_to cart_path, notice: "Order Duplicated."
    else
      redirect_to admin_order_path(order), alert: "Error duplicating order."
    end
  end

  def merge_order(orig_order, dest_order)
    result = MergeOrder.perform(user: current_user, orig_order: orig_order, dest_order: dest_order)
    if result.success?
      redirect_to admin_order_path(dest_order), notice: "Order Merged."
    else
      alert = 'Error merging order.'
      if !result.message.nil?
        alert = "#{alert} #{result.message}"
      else

      end
      redirect_to admin_order_path(orig_order), alert: alert
    end
  end

  def export_invoice(order, batch = nil)
    result = ExportInvoiceToQb.perform(order: order, curr_market: current_market, session: session)
    if batch.nil?
      if result.success?
        redirect_to admin_order_path(order), notice: "Invoice Exported to QB."
      else
        redirect_to admin_order_path(order), error: "Failed to Export Invoice."
      end
    end
  end

  def export_bill(order, batch = nil)
    result = ExportBillToQb.perform(order: order, curr_market: current_market, session: session)
    if batch.nil?
      if result.success?
        redirect_to admin_order_path(order), notice: "Bill Exported to QB."
      else
        redirect_to admin_order_path(order), error: "Failed to Export Bill."
      end
    end
  end

  def unclose_order(order, batch = nil)
    result = UncloseOrder.perform(order: order)
    if batch.nil?
      if result.success?
        redirect_to admin_order_path(order), notice: "Order Unclosed."
      else
        redirect_to admin_order_path(order), error: "Failed to Unclose Order."
      end
    end
  end

  protected

  def find_order_items(order_ids)
    order_items = OrderItem.includes({order: :delivery}).joins(:product).where(:order_id => order_ids)
    order_items
  end

  def order_params
    params[:order].delete(:delivery_id) # Remove the parameter so it doesn't conflict
    params[:order].delete(:delivery_clear) # Remove the parameter so it doesn't conflict
    params[:order].delete(:credit_clear) # Remove the parameter so it doesn't conflict
    params.require(:order).permit(:delivery_clear, :notes, :order_batch_action, :order_id, :signature_data, items_attributes: [
      :id, :quantity, :quantity_delivered, :delivery_status, :_destroy
    ])
  end

  def remove_delivery_fee(order)
    RemoveDeliveryFee.perform(order: order, orig_delivery_fees: order.delivery_fees, merge: false)
    redirect_to admin_order_path(order), notice: order.delivery.delivery_schedule.fee_label + " successfully removed."
  end

  def remove_credit(order)
    RemoveCredit.perform(order: order)
    redirect_to admin_order_path(order), notice: "Credit successfully removed."
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

  def undo_delivery(order)
    order = Order.find(params[:id])
    updates = UndoMarkDelivered.perform(user:current_user,order:order,delivery_id:params.require(:order)[:delivery_id])
    if updates.success?
      redirect_to admin_order_path(order), notice: "Delivery mark successfully reset."
    end
  end

  def items_to_add
    items = params.require(:items_to_add)
    items.select {|i| i[:quantity].to_i > 0 }
  end

  def setup_add_items_form(order)
    @show_add_items_form = true
    @order = SellerOrder.new(order, current_user, order.delivery_fees)
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
    recent_deliveries = order.market.deliveries.recent.active.uniq
    future_deliveries = order.market.deliveries.future.active.uniq

    @deliveries = recent_deliveries | future_deliveries | [order.delivery]
  end

  def perform_order_update(order, params, merge) # TODO this needs to handle price edits
    failed = false
    validate = ValidateOrderTotal.perform(order: order, order_params: params)
    if validate.success?
      updates = UpdateOrder.perform(payment_provider: order.payment_provider, order: order, order_params: params, request: request, merge: merge)
      if updates.success?
        order.update_total_cost
        came_from_admin = request.referer.include?("/admin/")
        next_url = if order.reload.items.any?
          came_from_admin ? admin_order_path(order) : order_path(order)
        else
          order.soft_delete
          came_from_admin ? admin_orders_path : orders_path
        end
        redirect_to next_url, notice: "Order successfully updated."
      else
        failed = true
        failed_order = updates.context[:order]
        #failed_order.update(items_attributes: updates.context[:previous_quantities])
        failed_order.errors.add(:payment_processor, "failed to update your payment") if updates.context[:status] == "failed"
       end
    else
      failed = true
      failed_order = validate.context[:order]
      failed_order.errors[:base] << "Order item must be greater than or equal to 0" if validate.context[:status] == "failed_qty"
      failed_order.errors[:base] << "Total cannot be negative" if validate.context[:status] == "failed_negative"
    end

    if failed
      if current_user.organization_ids.include?(failed_order.organization_id) || current_user.can_manage_organization?(failed_order.organization)
        @order = BuyerOrder.new(failed_order)
      else
        @order = SellerOrder.new(failed_order, current_user)
      end
      render :show
    end
  end

  def perform_add_items(order)
    result = UpdateOrderWithNewItems.perform(payment_provider: order.payment_provider, order: order, item_hashes: items_to_add, request: request)
    if !result.success?
      setup_add_items_form(order)
      order.errors[:base] << "Failed to add items to this order."
      render :show
      return false
    end
    if current_cart
      current_cart.destroy
    end
    session.delete(:cart_id)
    true
  end

  def show_add_items_form(order)
    setup_add_items_form(order)
    flash.now[:notice] = "Add items below."
    render :show
  end
end
