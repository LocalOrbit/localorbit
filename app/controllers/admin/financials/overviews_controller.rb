module Admin::Financials
  class OverviewsController < AdminController
    include StickyFilters

    before_action :find_sticky_params, only: [:show]

    def show

      base_scope, date_filter_attr = find_base_scope_and_date_filter_attribute

      @search_presenter = OrderSearchPresenter.new(@query_params, current_user, date_filter_attr)
      @q = filter_and_search_orders(base_scope, @query_params, @search_presenter)

      @orders = @q.result

      @overview = FinancialOverview.build(current_user, current_market, @orders)
    end

    private

    def find_base_scope_and_date_filter_attribute
        [Order.orders_for_seller(current_user), :placed_at]
    end

    def filter_and_search_orders(scope, params, presenter)
      query = scope.periscope(params).search(presenter.query)
      query
    end
  end
end
