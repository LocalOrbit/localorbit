class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, ApplyDiscountToAddedOrderItems, StoreOrderFees, UpdatePurchase, SendUpdateEmails, ClearInvoicePdf
end
