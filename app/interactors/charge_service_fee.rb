class ChargeServiceFee
  include Interactor::Organizer

  organize CreateServicePayment, ProcessPaymentWithBalanced, PaymentMadeEmailConfirmation
end
