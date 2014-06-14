class Admin::MetricsController < AdminController
  before_action :require_admin

  def index
    @presenter = MetricsPresenter.metrics_for(groups: [:financial], search: params[:q])
  end
end
