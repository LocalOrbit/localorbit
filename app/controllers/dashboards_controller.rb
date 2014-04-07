class DashboardsController < ApplicationController
  def show
    @presenter = DashboardPresenter.new(current_user, current_market)
    render @presenter.template
  end

  def coming_soon
  end
end
