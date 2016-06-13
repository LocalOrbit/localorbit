class RegisterStripeStandaloneMarket
  include Interactor::Organizer

  organize CreateOrganization, CreateMarket, CreateStripeCustomerForEntity
end
