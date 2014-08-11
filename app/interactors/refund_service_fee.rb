class RefundServiceFee
  include Interactor::Organizer

  organize RefundServicePayment, ProcessPaymentWithBalanced
end
