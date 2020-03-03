class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, UpdateLots, StoreOrderFees, UpdatePurchase, ClearInvoicePdf
end
