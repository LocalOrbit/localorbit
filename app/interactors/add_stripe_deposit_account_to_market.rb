class AddStripeDepositAccountToMarket
  include Interactor::Organizer

  organize [
    # CreateStripeCustomerForEntity,
    # CreateBankAccount,
    # AddCreditCardToStripeCustomer
  ]
end
