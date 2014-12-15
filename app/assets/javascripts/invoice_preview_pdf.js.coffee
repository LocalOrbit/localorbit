
KnockoutModules.register "invoice_preview_pdf",
  viewModel: (ko,el) ->
    PdfUriPoller.viewModel(ko,el)
  
