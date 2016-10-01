class UpdateOrder
  include Interactor::Organizer

  organize ValidateOrderTotal, UpdateQuantities, ApplyDiscountToAddedOrderItems, StoreOrderFees, UpdatePurchase, ClearInvoicePdf
end
