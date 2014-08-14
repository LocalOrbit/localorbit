module Admin::Financials
  class OfflinePaymentsController < AdminController
    def show
    end

    def create
      @payment = Payment.new(payment_params)
      if @payment.save
        redirect_to admin_financials_receipts_path, notice: "Offline payment successful"
      else
        flash.now[:alert] = "Offline payment error"
        render :show 
      end
    end

    private

    def payment_params
      params.require(:payment).permit(
        :payer_id, :payer_type, :payment_type, :amount, :created_at
      )
    end
  end
end
