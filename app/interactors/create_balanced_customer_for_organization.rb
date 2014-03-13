class CreateBalancedCustomerForOrganization
  include Interactor

  def perform
    customer = Balanced::Customer.new(balanced_customer_info).save
    organization.update_attribute(:balanced_customer_uri, customer.uri)
  end

  def balanced_customer_info
    {
      name: organization.name,
      meta: {
        organization_id: organization.id,
        organization_name: organization.name
      }
    }
  end
end
