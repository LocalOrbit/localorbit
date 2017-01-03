class ChargeServiceFee
  include Interactor::Organizer

  organize CreateStripeCustomerForEntity, CreateStripeSubscriptionForEntity
end
