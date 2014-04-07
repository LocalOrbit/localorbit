class DashboardsController < ApplicationController
  before_action :require_selected_market, unless: lambda { current_user.admin? }

  def show
    @presenter = DashboardPresenter.new(current_user, current_market)
  end

  def coming_soon
  end
end
