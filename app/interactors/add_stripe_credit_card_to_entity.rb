class AddStripeCreditCardToEntity
  include Interactor::Organizer

  def setup
    # context[:balanced_customer_uri] = entity.balanced_customer_uri
  end

  organize [
    # TODO CreateStripeCustomerForEntity,
    CreateBankAccount,
    # TODO UnderwriteStripeEntity,
    # TODO AddCreditCardToStripeCustomer
  ]
end
