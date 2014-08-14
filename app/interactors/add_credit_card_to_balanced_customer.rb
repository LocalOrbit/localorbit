class AddCreditCardToBalancedCustomer
  include Interactor

  def setup
    context[:balanced_customer] ||= entity.balanced_customer
  end

  def perform
    balanced_customer.add_card(bank_account.balanced_uri)
  end
end
