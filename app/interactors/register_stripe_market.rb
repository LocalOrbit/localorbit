class RegisterStripeMarket
  include Interactor::Organizer

  if FeatureAccess.stripe_standalone?(market: context[:market] || context[:entity])
    organize CreateMarket, CreateStripeCustomerForEntity
  else
    organize CreateMarket, CreateManagedStripeAccountForMarket, CreateStripeCustomerForEntity
  end
end
