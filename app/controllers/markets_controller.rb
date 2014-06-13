class MarketsController < ApplicationController
  before_action :hide_admin_navigation

  def show
    @market = current_market.decorate
  end
end
