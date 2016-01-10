class MarketsController < ApplicationController
  before_action :hide_admin_navigation
  before_action :require_selected_market

  def show
    @market = current_market.decorate
  end

  def new
  	# KXM This will likely be similar to the admin/registration piece, with a create feeding the new (or the other way around - cut me some slack, it's Sunday evening).
    @market = Market.new(payment_provider: PaymentProvider.for_new_markets.id)
  end
end
