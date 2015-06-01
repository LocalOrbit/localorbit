class AddStripeDepositAccountToMarket
  include Interactor::Organizer

  organize [
    CreateManagedStripeAccountForMarket,
    CreateBankAccount,
    AddBankAccountToManagedStripeAccount
  ]
end
