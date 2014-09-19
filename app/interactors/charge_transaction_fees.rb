class ChargeTransactionFees
  include Interactor::Organizer

  organize CreateTransactionFeePayment, ProcessPaymentWithBalanced, PaymentMadeEmailConfirmation
end
