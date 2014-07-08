module Admin
  class OrderItemsController < AdminController
    include Search::DateFormat
    include StickyFilters

    def index
      @order_items = OrderItem.for_user(current_user).joins(:order).preload(product: [:organization, :category], order: [:market, :organization])
      prepare_filter_data(@order_items)

      # initialize ransack and search
      @query_params = sticky_parameters(request.query_parameters)
      search = Search::QueryDefaults.new(@query_params[:q], :order_placed_at).query

      @q = @order_items.search(search)
      @q.sorts = ["order_placed_at desc", "name"] if @q.sorts.empty?
      @order_items = @q.result
      @totals = OrderTotals.new(@order_items)

      @start_date = format_date(search[:order_placed_at_date_gteq])
      @end_date = format_date(search[:order_placed_at_date_lteq])

      respond_to do |format|
        format.html { @order_items = @order_items.page(params[:page]).per(@query_params[:per_page]) }
        format.csv { @filename = "orders.csv" }
      end
    end

    def set_status
      UpdateOrderItemsStatus.perform(user: current_user, order_item_ids: params[:order_item_ids], delivery_status: params[:delivery_status])
      redirect_to action: :index
    end

    private

    def prepare_filter_data(order_items)
      @markets = Market.select(:id, :name).where(id: order_items.pluck("orders.market_id")).order(:name).uniq
      @sellers = Organization.select(:id, :name).where(id: order_items.joins(:product).pluck("products.organization_id")).order(:name).uniq
      @buyers = Organization.select(:id, :name).where(id: order_items.pluck("orders.organization_id")).order(:name).uniq
      @delivery_statuses = order_items.uniq.pluck(:delivery_status).sort
      @buyer_payment_statuses = Order.joins(:items).uniq.merge(order_items).pluck(:payment_status).sort
    end
  end
end
