class UpdatePaymentStatus
  include Interactor

  def perform
    if debit.status == 'succeeded' || debit.status == 'paid'
      payment.update(status: 'paid')
    elsif debit.status == 'failed'
      payment.update(status: 'failed')
    end
  end
end
