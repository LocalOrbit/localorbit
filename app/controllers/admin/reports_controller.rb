class Admin::ReportsController < AdminController
  before_action :require_admin_or_market_manager

  def index
    redirect_to [:admin, :reports, :total_sales]
  end

  def total_sales
  end
end
