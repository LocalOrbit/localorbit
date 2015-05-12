class AddStripeCreditCardToEntity
  include Interactor::Organizer

  def setup
    # context[:balanced_customer_uri] = entity.balanced_customer_uri
  end

  organize [
    CreateStripeCustomerForEntity,
    CreateBankAccount,
    # TODO ?? UnderwriteStripeEntity,
    AddCreditCardToStripeCustomer
  ]
end
