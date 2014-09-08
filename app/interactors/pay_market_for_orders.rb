class PayMarketForOrders
  include Interactor::Organizer

  organize CreateMarketPaymentForOrders, ProcessPaymentWithBalanced, PaymentReceivedEmailConfirmation
end
