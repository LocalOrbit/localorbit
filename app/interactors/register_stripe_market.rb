class RegisterStripeMarket
  include Interactor::Organizer

  organize CreateOrganization, CreateMarket, CreateManagedStripeAccountForMarket, CreateStripeCustomerForEntity
end
