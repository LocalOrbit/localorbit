
KnockoutModules.register "main_printables",
  viewModel: (ko, el) ->
    type = $(el).data("printable-type")
    vm =
      includeProductName: ko.observable false
      isPoster:           ko.observable type == 'poster'
      openNewTab:         ko.observable true

    vm.formTarget = ko.computed -> if vm.openNewTab() then "_blank" else null

    vm
