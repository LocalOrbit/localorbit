class Admin::FinancialsController < AdminController
  def index
    if current_user.seller? && !(current_user.admin? || current_user.market_manager?)
      @payments = Payment.where(payee_type: "Organization", payee_id: current_organization.id).order("updated_at DESC")

      render "payment_history"
    end
  end
end
