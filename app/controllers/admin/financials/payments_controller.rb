module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payments = Payment.where(payee: current_organization).order("updated_at DESC")
    end
  end
end
