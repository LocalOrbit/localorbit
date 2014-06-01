class Admin::PackListsController < AdminController
  before_action :require_admin_or_market_manager

  def show
    @delivery = Delivery.find(params[:id]).decorate
  end
end
