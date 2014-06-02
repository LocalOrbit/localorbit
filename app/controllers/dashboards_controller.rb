class DashboardsController < ApplicationController
  def show
    @presenter = DashboardPresenter.new(current_user, current_market, request.query_parameters)
    render @presenter.template
  end

  def coming_soon
  end
end
