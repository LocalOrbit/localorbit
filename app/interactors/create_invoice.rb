class CreateInvoice
  include Interactor::Organizer

  organize(
    MarkOrderInvoiced,
    SendInvoiceEmail
  )
end
