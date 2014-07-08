class UpdatePaymentStatus
  include Interactor

  def perform
    Payment.where(status: "pending").where.not(balanced_uri: nil).each do |payment|
      update_status(payment)
    end
  end

  def update_status(payment)
    debit = Balanced::Transaction.find(payment.balanced_uri)

    if debit.status == "succeeded" || debit.status == "paid"
      payment.update(status: "paid")

      if payment.payment_type == "order"
        payment.orders.each {|order| order.update(payment_status: "paid") }
      end
    elsif debit.status == "failed"
      payment.update(status: "failed")
    end
  rescue => e
    Honeybadger.notify_or_ignore(e) unless Rails.env.test? || Rails.env.development?
  end
end
