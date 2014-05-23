module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payment_history = PaymentHistoryPresenter.build(user: current_user,
                                                       organization: current_organization,
                                                       options: params)
    end
  end
end
