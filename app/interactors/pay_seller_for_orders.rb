class PaySellerForOrders
  include Interactor::Organizer

  organize CreateSellerPaymentForOrders, ProcessPaymentWithBalanced, PaymentReceivedEmailConfirmation
end
