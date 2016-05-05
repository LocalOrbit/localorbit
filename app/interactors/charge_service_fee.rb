class ChargeServiceFee
  include Interactor::Organizer

  organize CreateStripeCustomerForEntity, CreateStripeSubscriptionForEntity, CreateServicePayment, PaymentMadeEmailConfirmation
end
