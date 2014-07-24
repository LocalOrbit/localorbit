class Admin::MetricsController < AdminController
  before_action :require_admin

  def index
    redirect_to admin_metric_path("financials")
  end

  def show
    @presenter = MetricsPresenter.metrics_for(groups: [params[:id]], interval: params[:interval], markets: params[:market])

    render_404 unless @presenter
  end
end
