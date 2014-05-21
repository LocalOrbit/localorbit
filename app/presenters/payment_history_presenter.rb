class PaymentHistoryPresenter
  attr_reader :payments

  def self.build(user, organization)
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

    new(payments)
  end

  def initialize(payments)
    @payments = payments.decorate
  end
end
