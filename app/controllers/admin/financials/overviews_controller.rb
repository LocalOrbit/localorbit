module Admin::Financials
  class OverviewsController < AdminController
    def show
      klass = current_user.can_manage_market?(current_market) ? MarketManagerOverview : SellerOverview
      @overview = klass.new(seller: current_user, market: current_market)
    end
  end
end
