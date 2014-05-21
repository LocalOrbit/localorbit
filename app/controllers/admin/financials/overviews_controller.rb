module Admin::Financials
  class OverviewsController < AdminController
    def show
      @overview = FinancialOverview.build(current_user, current_market)
    end
  end
end
