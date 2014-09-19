class PayMarketForDeliveries
  include Interactor::Organizer

  organize CreateMarketPaymentForDeliveries, ProcessPaymentWithBalanced, PaymentReceivedEmailConfirmation
end
