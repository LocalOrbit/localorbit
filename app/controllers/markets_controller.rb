class MarketsController < ApplicationController
  def show
    @market = current_market.decorate
  end
end
