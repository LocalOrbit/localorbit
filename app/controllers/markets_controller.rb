class MarketsController < ApplicationController
  before_action :hide_admin_navigation
  before_action :find_market

  def show
  end

  def closed
  end

  private
  def find_market
    @market = current_market.decorate
  end
end
