class RegisterOrganization
  include Interactor::Organizer

  organize CreateOrganization, CreateBalancedCustomerForEntity
end
