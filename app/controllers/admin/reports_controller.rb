class Admin::ReportsController < AdminController
  include StickyFilters

  before_action :find_sticky_params, only: :show

  def index
    if current_user.buyer_only?
      show_page = admin_report_path("purchases-by-product")
    elsif current_user.market_manager?
      if FeatureAccess.not_LE_market_manager?(user: current_user, market: current_market)
        show_page = admin_report_path("total-sales")
      else
        show_page = admin_report_path("total-purchases")
      end
    else
      show_page = admin_report_path("total-sales")
    end
    redirect_to show_page
  end

  def show
    if params["clear"]
      redirect_to url_for(params.except(:clear))
    else
      @presenter = ReportPresenter.report_for(
        report: params[:id].to_s.underscore,
        market: current_market,
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
          format.csv do
            Delayed::Job.enqueue ::CSVExport::CSVReportExportJob.new(current_user, @presenter)
            flash[:notice] = "Please check your email for export results."
            redirect_to admin_reports_path
            #{ @filename = "report.csv" }
          end
        end
      else
        render_404
      end
    end
  end
end
