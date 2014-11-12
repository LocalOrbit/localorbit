
#
# Reusable view model that polls the current URI for JSON that provides
# an eventually-non-null pdfUri.
# (eg Table Tents and Posters, Packing Labels)
#
window.PdfUriPoller =
  viewModel: (ko, el) ->
    jsonPoller = new Util.JSONPoller()
    jsonPoller.start()
    pdfUriObservable = ko.computed ->
      jsonPoller.data()?.pdf_url || null

    pdfUriObservable.subscribe (uri) ->
      if uri?
        jsonPoller.stop()
        window.location = uri

    pdfUri: pdfUriObservable


