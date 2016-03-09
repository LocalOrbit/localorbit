class RegisterStripeStandaloneMarket
  include Interactor::Organizer

  organize CreateMarket, CreateStripeCustomerForEntity
end
