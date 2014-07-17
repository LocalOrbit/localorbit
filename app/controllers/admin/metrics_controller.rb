class Admin::MetricsController < AdminController
  before_action :require_admin

  def index
    redirect_to admin_metric_path("financials")
  end

  def show
    @presenter = MetricsPresenter.metrics_for(groups: [params[:metric]])

    if @presenter
      render :show
    else
      render_404
    end
  end
end
