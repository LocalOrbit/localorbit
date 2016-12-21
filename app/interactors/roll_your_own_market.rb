class RollYourOwnMarket
  include Interactor::Organizer

  organize [
    CreateOrganization,
    CreateMarket,
    CreateMarketAddress,
    CreateStripeCustomerForEntity,
    CreateStripeSubscriptionForEntity,
    CreateBankAccount,
    CreateServicePayment,
  ]
end
