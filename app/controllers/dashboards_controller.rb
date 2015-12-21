class DashboardsController < ApplicationController
  include StickyFilters

  before_action :find_sticky_params, only: :show

  def show
    if params["clear"]
      redirect_to url_for(params.except(:clear))
    else
      @query_params["placed_at_date_gteq"] ||= 7.days.ago.to_date.to_s
      @query_params["placed_at_date_lteq"] ||= Date.today.to_s
      @presenter = DashboardPresenter.new(current_user, current_market, request.query_parameters, @query_params)
      @q = search_and_calculate_totals(@presenter)

      @buyer_orders ||= @q.result
      @buyer_orders = @buyer_orders.page(params[:page]).per(@query_params[:per_page])

      render @presenter.template
    end
  end

  def coming_soon
  end

  def search_and_calculate_totals(query)
    results = Order.includes(:organization, :items, :delivery).orders_for_buyer(current_user).search(query.query)
    results.sorts = "placed_at desc" if results.sorts.empty?

    results
  end

end
