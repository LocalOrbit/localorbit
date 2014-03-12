class AddBankAccountToOrganization
  include Interactor::Organizer

  def setup
    context[:balanced_customer_uri] = organization.balanced_customer_uri
  end

  organize CreateBankAccount, AddBankAccountToBalancedCustomer
end
