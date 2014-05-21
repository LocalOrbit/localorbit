class PaymentHistoryPresenter
  attr_reader :payments

  def self.build(user, organization, page, per_page)
    scope = if user.admin?
      Payment.all
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
