class MarketsController < ApplicationController
  def index
    @market = current_user.markets.first.decorate
  end
end
