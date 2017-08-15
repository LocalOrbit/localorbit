module Admin
  module Financials
    class VendorPaymentsController < AdminController
      include StickyFilters
      
      before_action :find_sticky_params, only: :index
      before_action :require_admin_or_market_manager

      def index
        if params["clear"]
          redirect_to url_for(params.except(:clear))
        else
        end

        respond_to do |format|
          format.html do
            @search_presenter = PaymentSearchPresenter.new(user: current_user, query: @query_params)
            @finder = Search::SellerPaymentGroupFinder.new(user: current_user, query: @query_params, current_market: current_market)
            @sellers = @finder.payment_groups
          end
          format.csv do
            if ENV["USE_UPLOAD_QUEUE"] == "true"
              Delayed::Job.enqueue ::CSVExport::CSVVendorPaymentsExportJob.new(current_user, current_market, @query_params)
              flash[:notice] = "Please check your email for export results."
              redirect_to [:admin, :financials, :vendor_payments]
            else
              @filename = "vendor_payments.csv"
            end
          end
        end
      end

      def create
        seller = current_user.managed_organizations_including_deleted.find_by_id(params[:seller_id])
        payment = RecordVendorPayment.perform(seller: seller, payment_params: payment_params)
        redirect_to [:admin, :financials, :vendor_payments], payment.flash_message
      end

      protected

      def payment_params
        params.require(:payment).permit(:note, :payment_method, order_ids: [])
      end
    end
  end
end
