class RegisterStripeMarket
  include Interactor::Organizer

  organize CreateMarket, CreateManagedStripeAccountForMarket, CreateStripeCustomerForEntity
end
