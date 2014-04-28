module Admin::Financials
  class OverviewController < AdminController
    def index
      @overview = SellerOverview.new(seller: current_user, market: current_market)
    end
  end
end
