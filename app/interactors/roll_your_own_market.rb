class RollYourOwnMarket
  include Interactor::Organizer

  # KXM Interactor inspired by RegisterStripeMarket interactor, the following line coming directly from that
  # organize CreateMarket, CreateManagedStripeAccountForMarket, CreateStripeCustomerForEntity

  # Other interactors will be added here, once we have a better idea of what happens at what time
  organize CreateMarket
end
