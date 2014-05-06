class AddBankAccountToEntity
  include Interactor::Organizer

  def setup
    context[:balanced_customer_uri] = entity.balanced_customer_uri
  end

  organize [
    CreateBalancedCustomerForEntity,
    CreateBankAccount,
    UnderwriteEntity,
    AddBankAccountToBalancedCustomer,
    CreateBalancedBankAccountVerification
  ]
end
