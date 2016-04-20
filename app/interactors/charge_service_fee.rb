class ChargeServiceFee
  include Interactor::Organizer

  organize CreateServicePayment, ProcessPaymentWithStripe, PaymentMadeEmailConfirmation
end
