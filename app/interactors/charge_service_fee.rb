class ChargeServiceFee
  include Interactor::Organizer

  organize CreateServicePayment, ProcessPaymentWithBalanced
end
