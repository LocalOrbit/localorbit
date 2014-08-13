module Admin
  class OrderItemsController < AdminController
    include Search::DateFormat
    include StickyFilters

    def index
      items = fetch_order_items
      prepare_filter_data(items)

      # initialize ransack and search
      @query_params = sticky_parameters(request.query_parameters)
      search = Search::QueryDefaults.new(@query_params[:q], :order_placed_at).query

      @q = items.search(search)
      @q.sorts = ["order_placed_at desc", "name"] if @q.sorts.empty?

      @order_items = @q.result
      @totals = OrderTotals.new(@order_items)

      @start_date = format_date(search[:order_placed_at_date_gteq])
      @end_date = format_date(search[:order_placed_at_date_lteq])

      respond_to do |format|
        format.html { @order_items = @order_items.page(params[:page]).per(@query_params[:per_page]) }
        format.csv { @filename = "sold_items.csv" }
      end
    end

    def set_status
      UpdateOrderItemsStatus.perform(user: current_user, order_item_ids: params[:order_item_ids], delivery_status: params[:delivery_status])
      redirect_to action: :index
    end

    private

    def fetch_order_items
      OrderItem.for_user(current_user).
        joins(:order).
        includes(order: :organization, product: :organization).
        preload(product: [:organization, :category], order: [:market, :organization])
    end

    def prepare_filter_data(order_items)
      fetch_markets_list(order_items)
      fetch_sellers_list(order_items)
      fetch_buyers_list(order_items)
      fetch_delivery_statuses(order_items)
      fetch_buyer_payment_statuses(order_items)
    end

    def fetch_markets_list(order_items)
      @markets = Market.select(:id, :name).where(id: order_items.pluck("orders.market_id")).order(:name).uniq
    end

    def fetch_sellers_list(order_items)
      @sellers = Organization.select(:id, :name).where(id: order_items.joins(:product).pluck("products.organization_id")).order(:name).uniq
    end

    def fetch_buyers_list(order_items)
      @buyers = Organization.select(:id, :name).where(id: order_items.pluck("orders.organization_id")).order(:name).uniq
    end

    def fetch_delivery_statuses(order_items)
      @delivery_statuses = order_items.uniq.pluck(:delivery_status).sort
    end

    def fetch_buyer_payment_statuses(order_items)
      @buyer_payment_statuses = Order.joins(:items).uniq.merge(OrderItem.for_user(current_user)).pluck(:payment_status).sort
    end
  end
end
