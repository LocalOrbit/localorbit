class DashboardsController < ApplicationController
  def show
    @presenter = DashboardPresenter.new(current_user)
  end

  def coming_soon
  end
end
