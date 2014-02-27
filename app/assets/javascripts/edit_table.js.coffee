class @EditTable
  @build: (selector, opts={})->
    table = new EditTable(selector, opts)
    table.bindActions()
    table

  constructor: (selector, opts)->
    @form  = $(selector)
    @table = @form.find("table")
    @applyErrorValuesCallback = opts.applyErrorValuesCallback

    @hiddenRow = null
    @editing   = false
    @initialAction = @form.attr('action')
    @errorPayload  = @table.data("error-payload")

    if @errorPayload
      row = $("\##{@table.data("id-prefix")}_#{@errorPayload.id}")
      @openEditRow(row)
      @applyErrorValues(row, @errorPayload)

  # Lookups
  hiddenFormMethod: (method)->
    $("<input name=\"_method\" type=\"hidden\" value=\"#{method}\">")

  headerFieldsRow: ()->
    @form.find("table thead tr")

  relatedRow: (el)->
    idFromRel = $(el).attr("rel")
    $("#"+idFromRel)

  # Helpers
  disableFields: (el)->
    $(el).find("input,select").each ()->
      $(this).attr("readonly", true).attr("disabled", true)

  enableFields: (el)->
    $(el).find("input,select").each ()->
      $(this).removeAttr("readonly").removeAttr("disabled")

  setFormActionAndMethod: (action, method)->
    @form.attr('action', action)

    if method.toLowerCase() != "get" && method.toLowerCase() != "post"
      @form.append(@hiddenFormMethod(method))
    else
      @form.children("[name=_method]").remove()

  storeOriginalValues: (fieldsRow)->
    fieldsRow.find('input').each ->
      field = $(this)
      if !field.data('orginal-value')?
        field.data('orginal-value', field.val())

  restoreOriginalValues: (fieldsRow)->
    $(fieldsRow).find('input').each ->
      field = $(this)
      field.val(field.data('orginal-value'))
      if field.attr('step') == '0.01'
        field.val(parseFloat(field.val()).toFixed(2))

  applyErrorValues: (el, data)->
    fieldsRow = @relatedRow(el)

    $.each data, (item)=>
      field = $(fieldsRow).find($("input[name$='[#{item}]']"))
      $(field).val(data[item])

      # Apply Any Client-side formatting for fields
      if field.hasClass("datepicker")
        DatePicker.setup(field)

      if field.length && @applyErrorValuesCallback
        @applyErrorValuesCallback(field)

  # Main actions
  openEditRow: (row)->
    @closeEditRow(@editing, false) if @editing

    fieldsRow = @relatedRow(row)

    @storeOriginalValues(fieldsRow)

    action = fieldsRow.data('form-url')
    @setFormActionAndMethod(action, 'put')

    @disableFields(@headerFieldsRow())
    @enableFields(fieldsRow)

    @hiddenRow = row

    $(row).hide()
    $(fieldsRow).show()

    @editing = fieldsRow

  closeEditRow: (row, cancel)->
    @disableFields(row)
    $(row).hide()

    @restoreOriginalValues(row) if cancel
    @editing = false

    @enableFields(@headerFieldsRow())

    @setFormActionAndMethod(@initialAction, "post")

    $(@hiddenRow).show()
    @hiddenRow = null

  bindActions: ()->
    context = this
    @form.find("table tbody tr").on "click", ()->
      if $(this).data('form-url')?
        return

      context.openEditRow(this)

    @form.find("table tbody").on "click", 'tr .cancel', ()->
      row = $(this).parents("tr")[0]
      context.closeEditRow(row, true)

