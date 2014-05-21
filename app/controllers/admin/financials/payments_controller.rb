module Admin::Financials
  class PaymentsController < AdminController
    def index
      @payments = if current_user.admin?
        Payment.all
      elsif current_user.market_manager?
        market_ids = current_user.managed_market_ids
        Payment.joins("left join organizations on organizations.id = payments.payer_id").
                joins("left join market_organizations on market_organizations.organization_id = organizations.id").
                where("market_organizations.market_id in (:market_ids) OR (payments.payer_type = 'Market' AND payments.payer_id in (:market_ids)) OR (payments.payee_type = 'Market' AND payments.payer_id in (:market_ids))", market_ids: market_ids)
      else
        Payment.where(payee: current_organization)
      end.order("updated_at DESC").page(params[:page]).per(params[:per_page])
    end
  end
end
