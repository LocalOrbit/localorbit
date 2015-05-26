class UpdatePaymentStatus
  include Interactor

  def perform
    Payment.where(payment_provider: "balanced", status: "pending").where.not(balanced_uri: nil).each do |payment|
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
    if Rails.env.test? || Rails.env.development?
      raise e
    else
      Honeybadger.notify_or_ignore(e)
    end
  end
end
