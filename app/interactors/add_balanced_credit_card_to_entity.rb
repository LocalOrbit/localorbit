class AddBalancedCreditCardToEntity
  include Interactor::Organizer

  def setup
    context[:balanced_customer_uri] = entity.balanced_customer_uri
  end

  organize [
    CreateBalancedCustomerForEntity,
    CreateBankAccount,
    UnderwriteBalancedEntity, # TODO: rename to UnderwriteBalancedEntity
    AddCreditCardToBalancedCustomer
  ]
end
