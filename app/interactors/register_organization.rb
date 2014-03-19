class RegisterOrganization
  include Interactor::Organizer

  organize CreateOrganization, CreateBalancedCustomerForOrganization
end
