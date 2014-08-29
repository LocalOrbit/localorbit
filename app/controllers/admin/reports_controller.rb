class Admin::ReportsController < AdminController
  include StickyFilters

  before_action :find_sticky_params, only: :show

  def index
    redirect_to current_user.buyer_only?(current_market) ? admin_report_path("purchases-by-product") : admin_report_path("total-sales")
  end

  def show
    @presenter = ReportPresenter.report_for(
      report: params[:id].to_s.underscore,
      user: current_user,
      market_context: current_market,
      search: @query_params[:q],
      paginate: {
        csv: request.format.to_sym == :csv,
        page: @query_params[:page],
        per_page: @query_params[:per_page]
      })

    if @presenter
      respond_to do |format|
        format.html { render "report" }
        format.csv  { @filename = "report.csv" }
      end
    else
      render_404
    end
  end
end
