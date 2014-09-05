$ ->
  $('.product-table--admin .delete > a').hover (e) ->
    $(this).closest('tr').toggleClass('destructive')


  return unless $("form.product").length

  formView =
    updateLocations: (locations, selectedLocation)->
      productLocation = $("#product_location_id")
      productLocation.empty()

      $.each locations, (_, location) ->
        $("<option/>").attr("value", location.id)
                      .text(location.name)
                      .appendTo(productLocation)
      @addBlankLocation()

    selectLocation: (locId)->
      if !!locId
        option = $("#product_location_id option[value='#{locId}']")
        option.prop("selected", "selected")
      else
        option = $("#product_location_id option:first-child")
        option.prop("selected", false)

    applyFormValues: (opts)->
      @selectLocation(opts.location)
      $("#product_who_story").val(opts.who)
      $("#product_how_story").val(opts.how)

    hideFields: ->
      $(".seller_info_fields").addClass("hidden")
      @addBlankLocation()

    showFields: ->
      @removeBlankLocation()
      $(".seller_info_fields").removeClass("hidden")

    clearFields: ->
      @selectLocation(null)
      $("#product_who_story").val("")
      $("#product_how_story").val("")

    enableCheckbox: ->
      $("#seller_info").prop("disabled", false)

    disableCheckbox: ->
      $("#seller_info").prop("disabled", true)

    checkCheckbox: ->
      $("#seller_info").prop("checked", true)

    uncheckCheckbox: ->
      $("#seller_info").prop("checked", false)

    isCheckboxEnabledAndChecked: ->
      !$("#seller_info").prop("disabled") && $("#seller_info").prop("checked")

    removeBlankLocation: ->
      $("#product_location_id option[value='']").remove()

    addBlankLocation: ->
      $("<option value='' selected/>").text("Select a location")
                    .prependTo($("#product_location_id"))

  class window.FormModel
    @sanitizeOpts: (opts)->
      props = ["who", "how", "location", "selectedOrg"]

      $.each props, ()->
        if !!opts[this]
          opts[this] = opts[this]
        else
          opts[this] = null
      opts

    constructor: (opts)->
      @organizations = opts.organizations || []
      FormModel.sanitizeOpts(opts)

      @selectedOrg = opts.selectedOrg

      @who = opts.who
      @how = opts.how
      @location = opts.location

    update: (opts={})->
      opts = FormModel.sanitizeOpts(opts)

      @who = opts.who if opts.who
      @how = opts.how if opts.how
      @location = opts.location if opts.location

    setupStateForSellerInfo: ->
      if @defaultsToOrg()
        formView.checkCheckbox()
        formView.hideFields()
      else
        formView.uncheckCheckbox()
        formView.applyFormValues(@display())
        formView.showFields()

    setupStateForOrg: (orgId)->
      @selectedOrg = orgId
      if !!orgId
        formView.enableCheckbox()
        formView.updateLocations(@getOrg(orgId).locations)
        formView.selectLocation(@location)
        @setupStateForSellerInfo()
      else
        formView.checkCheckbox()
        formView.disableCheckbox()
        @changeSellerInfo(true)

    changeOrg: (newOrg)->
      if !!@selectedOrg
        if !!newOrg
          formView.updateLocations(@getOrg(newOrg).locations)
          formView.selectLocation(@location)
          if @selectedOrg != newOrg
            @who = null
            @how = null
            @location = null
            formView.applyFormValues(@display())
        else
          formView.checkCheckbox()
          formView.disableCheckbox()
          @changeSellerInfo(true)
      else
        if !!newOrg
          formView.enableCheckbox()
          formView.updateLocations(@getOrg(newOrg).locations)
          formView.selectLocation(@location)
        else
          formView.checkCheckbox()
          formView.disableCheckbox()
          @changeSellerInfo(true)

      @selectedOrg = newOrg

    changeSellerInfo: (checked)->
      if checked
        formView.hideFields()
        formView.clearFields()

      else
        formView.showFields()
        formView.applyFormValues(@display())

    changeVisibleInventory: (org) ->
      if org == ""
        $("#inventory").html("<h3 class='header-conditionals'>No Organization Selected</h3>")
      else
        $.get "/admin/organizations/#{org}/available_inventory", (response) ->
          $("#inventory").html(response)

    changeVisibleDeliveries: (org) ->
      if org == ""
        $("#delivery-schedules").html("<h3 class='header-conditionals'>No Organization Selected</h3>")
      else
        $("#delivery-schedules").html("<h3 class='header-conditionals'>Loading delivery schedules...</h3>")
        $.get "/admin/organizations/#{org}/delivery_schedules", (response) ->
          $("#delivery-schedules").html(response)

    changeDeliveries: (checked)->
      if checked
        $(".product-delivery-schedule input").prop("disabled", true).prop("checked", true)
      else
        $(".product-delivery-schedule input.optional-delivery").prop("disabled", false)

    display: ->
      if @defaultsToOrg() && !!@selectedOrg
        org = @getOrg(@selectedOrg)

        return {
          who: org.who_story,
          how: org.how_story,
          location: org.location_id
        }
      else
        return {
          who: @who || "",
          how: @how || "",
          location: @location || ""
        }

    defaultsToOrg: ->
      !(!!@who || !!@how || !!@location)

    getOrg: (id)->
      id = parseInt(id)
      organization = null
      $.each @organizations, (idx, org)->
        if org.id == id
          organization = org
      return organization


  ########################################
  # Data
  ########################################

  formModel = new FormModel({
    location: $("#product_location_id").val(),
    who: $("#product_who_story").val(),
    how: $("#product_how_story").val()
    organizations: $("form.product").data("organizations"),
    selectedOrg: $("#product_organization_id").val()

  })

  ########################################
  # Events
  ########################################

  $("#seller_info").change ->
    val = $(this).prop("checked")
    formModel.changeSellerInfo(val)

  $("#product_organization_id").change ->
    val = $(this).val()
    formModel.changeOrg(val)
    formModel.changeVisibleInventory(val)
    formModel.changeVisibleDeliveries(val)

  $("#product_use_all_deliveries").change ->
    val = $(this).prop("checked")
    formModel.changeDeliveries(val)

  formModel.setupStateForOrg($("#product_organization_id").val())

  $("#product_who_story, #product_how_story, #product_location_id").keyup ->
    formModel.update(
      who: $("#product_who_story").val(),
      how: $("#product_how_story").val(),
      location: $("#product_location_id").val()
    )

  $("#product_location_id").change ->
    formModel.update(
      location: $("#product_location_id").val()
    )

  $(document).on "change", '#product_use_simple_inventory', ->
    $('#simple-inventory').toggleClass('is-hidden')
    $('#product-inventory-nav').toggleClass('is-hidden pulsed')

  $('#product-save-and-return').click (e) ->
    e.preventDefault()

    form = $('form.product')
    form.attr("action", $(this).attr("href"))
    form.submit()


  $('.tab > .is-disabled').click (e) ->
    $('<div class="tab-error flash flash--alert"><p>' + $(this).attr('data-error') + '</p></div>').appendTo('.tab-header')
    window.setTimeout ->
        window.fade_flash()
      , 10
