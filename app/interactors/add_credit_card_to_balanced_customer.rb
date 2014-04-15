class AddCreditCardToBalancedCustomer
  include Interactor

  def setup
    context[:balanced_customer] ||= Balanced::Customer.find(balanced_customer_uri)
  end

  def perform
    balanced_customer.add_card(bank_account.balanced_uri)
  end
end
