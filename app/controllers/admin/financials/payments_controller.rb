module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payment_history = PaymentHistoryPresenter.build(user: current_user,
                                                       options: params,
                                                       paginate: params[:format] != "csv")
      respond_to do |format|
        format.html
        format.csv { @filename = "payments.csv" }
      end
    end

    def update
      @payment = Payment.find(params[:id])
      if @payment.update_attributes(payment_method:params[:payment][:payment_method], note:params[:payment][:note], amount:BigDecimal(params[:payment][:amount]))
        redirect_to "/admin/financials/payments"
      end


      # @delivery_note = DeliveryNote.find(params[:id])
      # if @delivery_note.update_attributes(payment_method:params[:payment][:payment_method
      #   ], note:params[:payment][:note], amount:BigDecimal(params[:payment][:amount]))
      #   redirect_to payment_history_path # well - the same path as the payments are shown on
      # end
    end

    def edit
      @payment = Payment.find(params[:id].to_i)
      #update
    end
  end
end
