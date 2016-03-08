class AddStripeDepositAccountToMarket
  include Interactor::Organizer

  if FeatureAccess.stripe_standalone?(market: current_market)
    organize CreateBankAccount, AddBankAccountToManagedStripeAccount
  else
    organize CreateManagedStripeAccountForMarket, CreateBankAccount, AddBankAccountToManagedStripeAccount
  end
end
