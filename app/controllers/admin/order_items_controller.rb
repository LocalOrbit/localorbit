module Admin
  class OrderItemsController < AdminController
    include Search::DateFormat
    include StickyFilters

    before_action :find_sticky_params

    def index
      items = fetch_order_items
      prepare_filter_data(items)

      # initialize ransack and search
      search = Search::QueryDefaults.new(@query_params[:q], :order_placed_at).query

      @q, @totals = perform_search_and_calculate_totals(items, search)
      @start_date, @end_date = find_search_date_range(search)

      respond_to do |format|
        format.html { @order_items = @q.result.page(params[:page]).per(@query_params[:per_page]) }
        format.csv do
          @order_items = @q.result
          @filename = "sold_items.csv"
        end
      end
    end

    def set_status
      UpdateOrderItemsStatus.perform(user: current_user, order_item_ids: params[:order_item_ids], delivery_status: params[:delivery_status])
      redirect_to action: :index
    end

    private

    def find_search_date_range(search)
      [
        format_date(search[:order_placed_at_date_gteq]),
        format_date(search[:order_placed_at_date_lteq])
      ]
    end

    def perform_search_and_calculate_totals(items, search)
      query = items.search(search)
      query.sorts = ["order_placed_at desc", "name"] if query.sorts.empty?

      if current_user.seller? && !current_user.admin?
        order_ids = query.result.map(&:id)
        order_items = OrderItem.includes(:product, :order).joins(:product).where(:order_id => order_ids, "products.organization_id" => current_user.managed_organization_ids_including_deleted)
        totals = OrderTotals.new(order_items)
      else
        totals = OrderTotals.new(OrderItem.where("1 = 0"))
      end
      [query, totals]
    end

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
      fetch_buyer_payment_statuses
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

    def fetch_buyer_payment_statuses
      @buyer_payment_statuses = Order.joins(:items).uniq.merge(OrderItem.for_user(current_user)).pluck(:payment_status).sort
    end
  end
end
