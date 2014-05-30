class AddBankAccountToBalancedCustomer
  include Interactor

  def setup
    context[:balanced_customer] ||= Balanced::Customer.find(entity.balanced_customer_uri)
  end

  def perform
    balanced_customer.add_bank_account(bank_account.balanced_uri)
  end
end
