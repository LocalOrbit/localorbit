
# <div data-ko-module="my_module"> .... </div>
#
# KnockoutModules.register "my_module", 
#   viewModel: (ko, el) -> {} // fn that retunrs a Knockout-JS-happy view model
#
# KnockoutModules.register "my_module", 
#   viewModel: viewModel
#   beforeApplyBindings: (ko,el) ->
#   afterApplyBindings: (ko,el,viewModel) ->
#
# KnockoutModules.register "my_module", 
#   applyBindings: (ko,el) ->

KM = {}
KM.modules = {}
KM.viewModels = {}
KM.register = (name, args={}) ->
  debug "Registering ko-module '#{name}':", args
  KM.modules[name] = args

debug = (args...) -> console.log "KnockoutModule setup:", args...
warn = (args...) -> console.log "KnockoutModule setup:", args...
    
KM.bootstrapModules = (ko) ->
  debug "Finding and bootstrapping any KnockoutModules in this page."
  $("div[data-ko-module]").each (_,el) ->
    debug "FOUND:", el
    module_name = $(el).data("ko-module")
    module = KM.modules[module_name]
    debug "ko-module #{module_name}:", KM.modules[module_name]
    if module?
      debug "Bootstrapping ko-module '#{module_name}'..."
      module.beforeApplyBindings?(ko,el)

      viewModel = if module.viewModel
        if typeof module.viewModel == "function"
          window.wtff = ko
          module.viewModel(ko,el)
        else
          module.viewModel

      if module.applyBindings?
        debug "Bootstrapping ko-module '#{module_name}': invoking custom applyBindings()"
        maybeViewModel = module.applyBindings(ko, el)
        module.afterApplyBindings?(ko, el, maybeViewModel)
        KM.viewModels[module_name] = maybeViewModel
      else if viewModel
        debug "Bootstrapping ko-module '#{module_name}': applying viewModel", viewModel
        ko.applyBindings(viewModel, el)
        module.afterApplyBindings?(ko, el, viewModel)
        KM.viewModels[module_name] = viewModel
      else
        warn "ko-module #{module_name} doesn't provide an override for applyBindings(ko,el), nor does it provide a viewModel. Aborting."
    else
      warn "No ko-module registered for name '#{module_name}'"

window.KnockoutModules = KM
$(-> KM.bootstrapModules(ko))
