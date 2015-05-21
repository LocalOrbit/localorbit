module Admin
  module Financials
    class VendorPaymentsController < AdminController
      before_action :require_admin_or_market_manager

      def index
        @search_presenter = PaymentSearchPresenter.new(user: current_user, query: request.query_parameters)
        @finder = Search::SellerPaymentGroupFinder.new(user: current_user, query: request.query_parameters, current_market: current_market)
        @sellers = @finder.payment_groups
      end

      def create
        # FIXME: This should likely use managed_organizations_including_deleted instead of managed_organizations.
        # However, it's unclear whether managed_organizations_including_deleted's only difference from managed_organizations
        # is including the deleted records (the implementations look to differ in more ways than simply that)
        seller = current_user.managed_organizations.find(params[:seller_id])
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
