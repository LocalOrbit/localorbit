
##########################

viewModel = (ko, el) ->
  vm =
    printableType: ko.observable $(el).data("printable-type")
    includeProductName: ko.observable false

  vm.isPoster           = ko.computed -> vm.printableType() == "poster"
  vm.showPoster         = ko.computed -> vm.isPoster() and !vm.includeProductName()
  vm.showPosterWithName = ko.computed -> vm.isPoster() and vm.includeProductName()

  vm.isTableTent           = ko.computed -> vm.printableType() != "poster"
  vm.showTableTent         = ko.computed -> vm.isTableTent() and !vm.includeProductName()
  vm.showTableTentWithName = ko.computed -> vm.isTableTent() and vm.includeProductName()

  vm

KnockoutModules.register "main_printables", viewModel: viewModel
  # beforeApplyBindings: (ko,el) ->
  # applyBindings: (ko,el) ->
  # afterApplyBindings: (ko,el,viewModel) ->
