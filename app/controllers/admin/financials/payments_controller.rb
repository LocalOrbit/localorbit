module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payments = if current_user.admin?
        Payment.all
      elsif current_user.market_manager?
        ids = current_user.managed_market_ids
        Payment.joins(from_organization: :markets).where(markets: { id: ids })
      else
        Payment.where(payee: current_organization)
      end.order("updated_at DESC").decorate
    end
  end
end
