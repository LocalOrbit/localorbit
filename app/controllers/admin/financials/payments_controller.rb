module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payment_history = PaymentHistoryPresenter.new(user: current_user,
                                                       options: params,
                                                       paginate: params[:format] != "csv")
      respond_to do |format|
        format.html
        format.csv { @filename = "payments.csv" }
      end
    end

    def edit
      @payment = Payment.find(params[:id].to_i)
    end

    def update
      @payment = Payment.find(params[:id])
      @payment.update_attributes!(payment_method:params[:payment][:payment_method], note:params[:payment][:note])#, amount:BigDecimal(params[:payment][:amount]))
      redirect_to admin_financials_payments_path
    end

  end
end
