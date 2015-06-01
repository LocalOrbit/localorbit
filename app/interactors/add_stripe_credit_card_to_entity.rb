class AddStripeCreditCardToEntity
  include Interactor::Organizer

  organize [
    CreateStripeCustomerForEntity,
    CreateBankAccount,
    AddCreditCardToStripeCustomer
  ]
end
