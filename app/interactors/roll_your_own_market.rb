class RollYourOwnMarket
  include Interactor::Organizer

  organize [
  	CreateMarket, 
  	CreateMarketAddress, 
  	CreateBankAccount,
  	CreateServicePayment,
  	CreateStripeCustomerForEntity, 
  	CreateStripeSubscriptionForEntity,
  ]
end
