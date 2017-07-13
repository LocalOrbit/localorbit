class Admin::ConsignmentPartialPoReportController < AdminController
  include StickyFilters

  before_action :find_sticky_params, only: [:show]

  def show
    @search_presenter = OrderSearchPresenter.new(@query_params, current_user, :placed_at)
    @q = search_orders(@search_presenter)

    @orders = @q.result(distinct: true)
  end

  def search_orders(search)
    results = Order.where(market_id: current_market.id, order_type: 'purchase', sold_through: false).visible.search(search.query)
    results.sorts = "placed_at" if results.sorts.empty?
    results
  end
end