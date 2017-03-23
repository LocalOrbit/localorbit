class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, UpdateLots, UpdateConsignmentTransaction, StoreOrderFees, UpdatePurchase, ClearInvoicePdf
end
