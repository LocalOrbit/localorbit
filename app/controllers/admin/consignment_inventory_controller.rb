class Admin::ConsignmentInventoryController < AdminController
  include StickyFilters

  before_action :find_sticky_params, only: :index

  def index
    if params["clear"]
      redirect_to url_for(params.except(:clear))
    else
      @search_presenter = ConsignmentInventorySearchPresenter.new(@query_params, current_user, nil)
      @q = search_products(@search_presenter)

      @inventories = @q.result(distinct: true)

      respond_to do |format|
        format.html do
          @inventories = @inventories.page(params[:page]).per(@query_params[:per_page])
        end
      end
    end
  end

  def search_products(search)

    results = ConsignmentTransaction.joins(product: [:organization])
    .joins("LEFT JOIN lots ON lots.id = consignment_transactions.lot_id")
    .joins("INNER JOIN consignment_transactions ct ON ct.order_id != consignment_transactions.order_id AND ct.transaction_type = 'HOLDOVER' AND ct.quantity > 0")
    .where("consignment_transactions.market_id = ?", current_market.id)
    .where(transaction_type: 'PO')
    .visible
    .select("products.id product_id,
    products.name AS product_name,
    organizations.id AS supplier_id,
    organizations.name AS supplier_name,
    consignment_transactions.order_id,
    (SELECT DISTINCT notes FROM consignment_transactions, orders WHERE consignment_transactions.order_id = orders.id AND consignment_transactions.lot_id = lots.id AND transaction_type = 'PO') order_note,
    CASE WHEN consignment_transactions.lot_id IS NULL THEN 'waiting' ELSE 'onhand' END AS status,
    consignment_transactions.quantity AS ct_quantity,
    lots.number AS lot_number,
    lots.quantity AS lot_quantity")
    .order("products.name")
    .search(search.query)

    #results.sorts = "name asc" if results.sorts.empty?
    results
  end
end