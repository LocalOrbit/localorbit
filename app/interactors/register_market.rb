class RegisterMarket
  include Interactor::Organizer

  organize CreateMarket, CreateBalancedCustomerForMarket
end
