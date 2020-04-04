class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, StoreOrderFees, UpdatePurchase, ClearInvoicePdf
end
