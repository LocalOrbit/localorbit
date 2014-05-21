module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payments = if current_user.admin?
        Payment.all
      else
        Payment.where(payee: current_organization)
      end.order("updated_at DESC").decorate
    end
  end
end
