module Admin
  class OrderItemsController < AdminController
    include Search::DateFormat
    include StickyFilters

    before_action :find_sticky_params, only: :index

    def index
      if params['clear']
        redirect_to url_for(params.except(:clear))
      else
        items = fetch_order_items
        prepare_filter_data(items)

        # initialize ransack and search
        search = Search::QueryDefaults.new(@query_params[:q], :order_placed_at).query

        @q, @totals = perform_search_and_calculate_totals(items, search)
        @start_date, @end_date = find_search_date_range(search)

        respond_to do |format|
          format.html { @order_items = @q.result.page(params[:page]).per(@query_params[:per_page]) }
          format.csv do
            Delayed::Job.enqueue ::CSVExport::CSVSoldItemsExportJob.new(current_user, @q.result.map(&:id)), priority: 30
            flash[:notice] = 'Please check your email for export results.'
            redirect_to admin_order_items_path
          end
        end
      end
    end

    def set_status
      UpdateOrderItemsStatus.perform(user: current_user, order_item_ids: params[:order_item_ids], delivery_status: params[:delivery_status])
      redirect_to action: :index
    end

    def show
      @order_item = OrderItem.find(params[:id])
    end

    def update
      @order_item = OrderItem.find(params[:id])
      @order = Order.find(params[:order_id])
      if params[:order_item][:unit_price]
        @order_item.unit_price = params[:order_item][:unit_price]
        @order_item.net_price = params[:order_item][:net_price]
        sof = StoreOrderFees.new
        sof.update_accounting_fees_for(@order_item)
        # TODO: is this the only specific update that's needed?
        # There may be a more general/prettier way to do this, updating the order totals overall.
        @order_item.save!
        @order.update_total_cost
        @order.save!
      end
      redirect_to admin_order_path(params[:order_id])
    end

    private

    def find_search_date_range(search)
      [
        format_date(search[:order_placed_at_date_gteq]),
        format_date(search[:order_placed_at_date_lteq])
      ]
    end

    def perform_search_and_calculate_totals(items, search)
      query = items.includes(:product, :order).search(search)
      query.sorts = ['order_placed_at desc', 'name'] if query.sorts.empty?
      [query, OrderTotals.new(query.result)]
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
      @markets = Market.select(:id, :name).where(id: order_items.pluck('orders.market_id')).order(:name).uniq
    end

    def fetch_sellers_list(order_items)
      @sellers = Organization.select(:id, :name).where(
        org_type: Organization::TYPE_SUPPLIER,
        id: order_items.joins(:product).pluck('products.organization_id')
      ).order(:name).uniq
    end

    def fetch_buyers_list(order_items)
      @buyers = Organization.select(:id, :name).where(
        org_type: Organization::TYPE_BUYER,
        id: order_items.pluck('orders.organization_id')
      ).order(:name).uniq
    end

    def fetch_delivery_statuses(order_items)
      @delivery_statuses = order_items.uniq.pluck(:delivery_status).sort
    end

    def fetch_buyer_payment_statuses
      @buyer_payment_statuses = Order.joins(:items).uniq.merge(OrderItem.for_user(current_user)).pluck(:payment_status).sort
    end
  end
end
