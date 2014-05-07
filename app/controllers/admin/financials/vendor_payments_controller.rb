module Admin
  module Financials
    class VendorPaymentsController < AdminController
      before_action :require_admin_or_market_manager

      def index
        @sellers = SellerPaymentGroup.for_user(current_user)
      end

      def create
        seller = current_user.managed_organizations.find(params[:seller_id])
        payment = RecordVendorPayment.perform(seller: seller, payment_params: payment_params)
        redirect_to [:admin, :financials, :vendor_payments], payment.flash_message
      end

      protected

      def payment_params
        params.require(:payment).permit(:note, :payment_type, order_ids: [])
      end
    end
  end
end
