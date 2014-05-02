module Admin
  module Financials
    class VendorPaymentsController < AdminController
      before_action :require_admin_or_market_manager

      def index
        @sellers = SellerPaymentGroup.for_user(current_user)
      end
    end
  end
end
