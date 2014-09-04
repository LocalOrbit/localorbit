class GenerateInvoicePdfAndSend
  include Interactor::Organizer

  organize(
    GenerateInvoicePdf,
    SendInvoiceEmails
  )
end
