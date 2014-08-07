class OrderPayment < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :order
  belongs_to :payment

  def self.market_paid_orders_subselect(payment_type)
    select(:order_id).
      joins(:payment).
      where.not(payments: {status: "failed"}).
      where(payments: {payment_type: payment_type, payee_type: "Market"}).
      where(Payment.arel_table[:payee_id].eq(Order.arel_table[:market_id])).
      uniq
  end
end
