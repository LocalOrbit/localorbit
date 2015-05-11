class AddBalancedBankAccountToEntity
  include Interactor::Organizer

  organize [
    CreateBalancedCustomerForEntity,
    CreateBankAccount,
    UnderwriteEntity,
    AddBankAccountToBalancedCustomer,
    CreateBalancedBankAccountVerification
  ]
end
