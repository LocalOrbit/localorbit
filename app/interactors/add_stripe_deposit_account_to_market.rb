class AddStripeDepositAccountToMarket
  include Interactor::Organizer

  organize [
    #TODO: CreateManagedStripeAccountForMarket,
    # CreateBankAccount,
    # TODO: AddBankAccountToManagedStripeAccount
  ]
end
