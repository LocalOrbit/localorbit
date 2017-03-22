class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, UpdateConsignmentTransaction, StoreOrderFees, UpdatePurchase, ClearInvoicePdf
end
