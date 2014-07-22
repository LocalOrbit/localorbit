class Admin::ReportsController < AdminController
  include StickyFilters

  def index
    redirect_to current_user.buyer_only? ? admin_report_path("purchases-by-product") : admin_report_path("total-sales")
  end

  def show
    @query_params = sticky_parameters(request.query_parameters)
    @presenter = ReportPresenter.report_for(
      report: params[:id].to_s.underscore,
      user: current_user,
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
