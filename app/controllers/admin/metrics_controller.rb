class Admin::MetricsController < AdminController
  before_action :require_admin

  def index
    @presenter = MetricsPresenter.metrics_for(
      metrics: [:financial],
      user: current_user,
      search: params[:q]
    )
  end
end
