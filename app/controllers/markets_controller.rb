class MarketsController < ApplicationController
  before_action :hide_admin_navigation
  before_action :require_selected_market

  def show
    @market = current_market.decorate
  end
end
