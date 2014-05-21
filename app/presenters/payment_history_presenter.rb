class PaymentHistoryPresenter
  attr_reader :payments

  def self.build(user, organization, page, per_page)
    scope = if user.admin?
      Payment.all
    elsif user.market_manager?
      market_ids = user.managed_market_ids

      Payment.joins("left join organizations on organizations.id = payments.payer_id").
        joins("left join market_organizations on market_organizations.organization_id = organizations.id").
        where("market_organizations.market_id in (:market_ids) OR (payments.payer_type = 'Market' AND payments.payer_id in (:market_ids)) OR (payments.payee_type = 'Market' AND payments.payer_id in (:market_ids))", market_ids: market_ids)
    elsif user.buyer_only?
      Payment.joins(:order_payments)
      .includes(:orders)
      .where(orders: {organization_id: organization.id, payment_status: 'paid'})
    else
      Payment.where(payee: organization)
    end

    payments = scope.order("payments.updated_at DESC")

    new(payments, page, per_page)
  end

  def initialize(payments, page, per_page)
    @payments = payments.page(page).per(per_page)
  end
end
