class Admin::FinancialsController < AdminController
  def index
    if current_user.seller? && !(current_user.admin? || current_user.market_manager?)
      @payments = Payment.where(payee: current_organization).order("updated_at DESC")

      render "payment_history"
    end
  end
end
