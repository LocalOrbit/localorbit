class @EditTable
  @build: (opts={})->
    table = new EditTable(opts)
    table.bindActions()
    table

  constructor: (opts)->
    @form  = $(opts.selector)
    @table = @form.find("table")
    @applyErrorValuesCallback = opts.applyErrorValuesCallback

    @hiddenRow = null
    @editing   = false
    @initialAction = @form.attr('action')
    @errorPayload  = @table.data("error-payload")

    if @errorPayload
      row = $("\##{@table.data("id-prefix")}_#{@errorPayload.id}")
      @enableEditForRow(row)
      @applyErrorValues(row, @errorPayload)

  hiddenFormMethod: (method)->
    $("<input name=\"_method\" type=\"hidden\" value=\"#{method}\">")

  headerFieldsRow: ()->
    @form.find("table thead tr")

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

  relatedRow: (el)->
    idFromRel = $(el).attr("rel")
    $("#"+idFromRel)

  storeOriginalValues: (fieldsRow)->
    return if $(fieldsRow.find('input')[0]).data('original-value')?

    fieldsRow.find('input').each ->
      field = $(this)
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

  enableEditForRow: (row)->
    return if @editing

    fieldsRow = @relatedRow(row)

    @storeOriginalValues(fieldsRow)

    action = fieldsRow.data('form-url')
    @setFormActionAndMethod(action, 'put')

    @disableFields(@headerFieldsRow())
    @enableFields(fieldsRow)

    @hiddenRow = row

    $(row).hide()
    $(fieldsRow).show()

    @editing = true

  bindActions: ()->
    context = this
    @form.find("table tbody tr").on "click", ()->
      if $(this).data('form-url')?
        return

      context.enableEditForRow(this)

    @form.find("table tbody").on "click", 'tr .cancel', ()->
      row = $(this).parents("tr")[0]
      context.enableFields(context.headerFieldsRow())

      context.setFormActionAndMethod(context.initialAction, "post")

      $(context.hiddenRow).show()
      context.hiddenRow = null

      context.disableFields(row)
      $(row).hide()
      context.restoreOriginalValues(row)
      context.editing = false

