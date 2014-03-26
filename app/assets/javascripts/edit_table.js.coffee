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
    @initialAction = @form.attr("action")
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
    @form.attr("action", action)

    if method.toLowerCase() != "get" && method.toLowerCase() != "post"
      @form.append(@hiddenFormMethod(method))
    else
      @form.children("[name=_method]").remove()

  restoreOriginalValues: (fieldsRow)->
    $(fieldsRow).find("input").each ->
      field = $(this)
      field.val(field.attr("value"))

    $(fieldsRow).find("select").each ->
      field = $(this)
      field.val(field.find('option[selected=selected]').attr('value'))

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
    @closeEditRow(@form.find('.open-row'), false)

    fieldsRow = @relatedRow(row)

    action = fieldsRow.data("form-url")
    @setFormActionAndMethod(action, "put")

    @disableFields(@headerFieldsRow())
    @enableFields(fieldsRow)

    @hiddenRow = row

    row.hide()
    fieldsRow.show()
    fieldsRow.addClass('open-row')

  openAddRow: ()->
    @closeEditRow(@form.find('.open-row'), false)

    fieldsRow = $("#add-row")

    @enableFields(fieldsRow)

    fieldsRow.show()
    fieldsRow.addClass('open-row')

  closeEditRow: (row, cancel)->
    return if row.length == 0

    @disableFields(row)
    row.hide()
    row.removeClass('open-row')
    $(".add-toggle").show() if row.attr("id") == "add-row"

    @restoreOriginalValues(row) if cancel

    @enableFields(@headerFieldsRow())

    @setFormActionAndMethod(@initialAction, "post")

    @hiddenRow.show() if @hiddenRow != null
    @hiddenRow = null

  bindActions: ()->
    context = this
    @form.on "click", ".edit-trigger", (e)->
      e.preventDefault()
      context.openEditRow($($(this).parents("tr")[0]))

    @form.on "click", "tr .cancel", (e)->
      e.preventDefault()
      row = $($(this).parents("tr")[0])
      context.closeEditRow(row, true)

    @form.on "click", ".add-toggle", (e) ->
      e.preventDefault()
      $(this).hide()
      context.openAddRow()

    @form.on "click", ".delete-selected", (e) ->
      e.preventDefault()
      context.setFormActionAndMethod(@initialAction, "delete")
      context.form.submit()
