class PayMarketForOrders
  include Interactor::Organizer

  organize CreateMarketPaymentForOrders, ProcessPaymentWithBalanced
end
