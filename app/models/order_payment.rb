class OrderPayment < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :order
  belongs_to :order
  belongs_to :payment

  def self.market_paid_orders_subselect(payment_type, type=:payee)
    select(:order_id).
      joins(:payment).
      where.not(payments: {status: "failed"}).
      where(payments: {payment_type: payment_type, "#{type}_type" => "Market"}).
      where(Payment.arel_table["#{type}_id"].eq(Order.arel_table[:market_id])).
      uniq
  end
end
