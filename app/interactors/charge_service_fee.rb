class ChargeServiceFee
  include Interactor::Organizer

  organize CreateServicePayment, PaymentMadeEmailConfirmation
end
