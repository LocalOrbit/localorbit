module Admin::Financials
  class OverviewsController < AdminController
    def show
      @overview = SellerOverview.new(seller: current_user, market: current_market)
    end
  end
end
