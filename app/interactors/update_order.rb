class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, StoreOrderFees, UpdatePurchase, SendUpdateEmails, ClearInvoicePdf
end
