class AddBalancedBankAccountToEntity
  include Interactor::Organizer

  organize [
    CreateBalancedCustomerForEntity,
    CreateBankAccount,
    UnderwriteBalancedEntity,
    AddBankAccountToBalancedCustomer,
    CreateBalancedBankAccountVerification
  ]
end
