module Admin
  module Financials
    class ReceiptsController < AdminController
      def index
        @orders = for_receipts.order('orders.invoice_due_date').page(params[:page]).per(params[:per_page])
      end

      def edit
        @order   = for_receipts.find(params[:id])
        @payment = @order.payments.build
      end

      def update
        @buyer_payment = RecordBuyerPayment.perform(order: for_receipts.find(params[:id]), payment_params: payment_params)
        if @buyer_payment.success?
          redirect_to admin_financials_receipts_path, notice: "Payment recorded for order #{@buyer_payment.order.order_number}"
        else
          @order   = @buyer_payment.order
          @payment = @buyer_payment.payment
          render :edit
        end
      end

      protected

      def for_receipts
        Order.orders_for_seller(current_user).invoiced.unpaid
      end

      def payment_params
        params.require(:payment).permit(:payment_method, :amount, :note)
      end
    end
  end
end
