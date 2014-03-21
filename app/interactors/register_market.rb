class RegisterMarket
  include Interactor::Organizer

  organize CreateMarket, CreateBalancedCustomerForEntity
end
