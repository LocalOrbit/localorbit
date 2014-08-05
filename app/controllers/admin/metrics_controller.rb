class Admin::MetricsController < AdminController
  before_action :require_admin

  def index
    redirect_to admin_metric_path("financials")
  end

  def show
    @presenter = MetricsPresenter.metrics_for(
      groups: [params[:id]],
      interval: params[:interval],
      markets: params[:market],
      start_date: params[:start_date].try(:to_date),
      end_date: params[:end_date].try(:to_date))

    render_404 unless @presenter
  end
end
