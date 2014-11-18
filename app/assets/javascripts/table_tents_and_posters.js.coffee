
KnockoutModules.register "main_printables",
  viewModel: (ko, el) ->
    type = $(el).data("printable-type")
    vm =
      includeProductName: ko.observable false
      isPoster:           ko.observable type == 'poster'

    vm.formTarget = ko.computed -> if KnockoutModules.testMode() then null else "_blank"
    vm

KnockoutModules.register "download_printables",
  viewModel: (ko,el) ->
    PdfUriPoller.viewModel(ko,el)

