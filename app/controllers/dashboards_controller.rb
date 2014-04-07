class DashboardsController < ApplicationController
  def show
    @presenter = DashboardPresenter.new(current_user, current_market || current_user.markets.first)
  end

  def coming_soon
  end
end
