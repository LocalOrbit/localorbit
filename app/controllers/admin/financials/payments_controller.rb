module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payment_history = PaymentHistoryPresenter.build(user: current_user,
                                                       organization: current_organization,
                                                       options: params)
      respond_to do |format|
        format.html
        format.csv { @filename = "payments.csv" }
      end
    end
  end
end
