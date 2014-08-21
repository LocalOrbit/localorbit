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
  end
end
