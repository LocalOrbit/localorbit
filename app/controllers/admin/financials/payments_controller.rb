module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payment_history = PaymentHistoryPresenter.build(current_user, current_organization, params[:page], params[:per_page])
    end
  end
end
