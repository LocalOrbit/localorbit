module Admin
  module Financials
    class LoPaymentsController < AdminController
      def index
        orders = Order.payable_lo_fees.clean_payment_records.preload(:items, :market).joins(:market).order("MAX(markets.name)", "orders.order_number")
        @orders_by_market = orders.group_by(&:market)
      end

      def create
        @charge_market = ChargeTransactionFees.perform(user: current_user, market_id: params[:market_id], bank_account_id: params[:bank_account_id], order_ids: params[:order_ids])
        if @charge_market.success?
          redirect_to admin_financials_lo_payments_path, notice: "Payment recorded"
        else
          redirect_to admin_financials_lo_payments_path, alert: "Payment failed"
        end
      end
    end
  end
end
