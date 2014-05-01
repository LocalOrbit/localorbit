class UpdatePaymentStatus
  include Interactor

  def perform
    if debit.status == 'succeeded' || debit.status == 'paid'
      payment.update(status: 'paid')

      payment.orders.each do |order|
        order.update(payment_status: 'paid')
      end
    elsif debit.status == 'failed'
      payment.update(status: 'failed')
    end
  end
end
