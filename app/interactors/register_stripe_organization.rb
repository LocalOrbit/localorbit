class RegisterStripeOrganization
  include Interactor::Organizer

  organize CreateOrganization, CreateStripeCustomerForEntity
end
