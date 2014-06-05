class Admin::ReportsController < AdminController
  before_action :require_admin_or_market_manager

  def total_sales
  end
end
