class RegisterStripeMarket
  include Interactor::Organizer

  if FeatureAccess.stripe_standalone?(market: current_market)
    organize CreateMarket, CreateStripeCustomerForEntity
  else
    organize CreateMarket, CreateManagedStripeAccountForMarket, CreateStripeCustomerForEntity
  end
end
