class Admin::ReportsController < AdminController
  def index
    redirect_to current_user.buyer_only? ? admin_report_path("purchases-by-product") : admin_report_path("total-sales")
  end

  def show
    @presenter = ReportPresenter.report_for(
      report: params[:report].to_s.underscore,
      user: current_user,
      search: params[:q],
      paginate: {
        csv: request.format.to_sym == :csv,
        page: params[:page],
        per_page: params[:per_page]
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
