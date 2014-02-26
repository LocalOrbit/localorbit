class @EditTable
  @build: (opts={})->
    table = new EditTable(opts)
    table.bindActions()
    table

  constructor: (opts)->
    @form = $(opts.selector)
    @modelPrefix = opts.modelPrefix

    @hiddenRow = null
    @originalFields = null
    @editing = false
    @initialAction = @form.attr('action')
    @errorPayload = @form.find("table").data("error-payload")

    if @errorPayload
      row = $("#" + "#{@modelPrefix}_" + @errorPayload.id)
      @enableEditForRow(row)
      @applyErrorValues(row, @errorPayload)

  hiddenPutMethod:  ()->
    $('<input name="_method" type="hidden" value="put">')

  headerFieldsRow: ()->
    @form.find("table thead tr")

  # Helpers
  disableFields: (el)->
    $(el).find("input").each ()->
      $(this).attr("readonly", true)
      $(this).attr("disabled", true)

  enableFields: (el)->
    $(el).find("input").each ()->
      $(this).removeAttr("readonly")
      $(this).removeAttr("disabled")

  setFormActionAndMethod: (action, method)->
    @form.attr('action', action)

    if method.toLowerCase() == "put"
      @form.append(@hiddenPutMethod())
    else
      $("[name=_method]").remove()

  relatedRow: (el)->
    idFromRel = $(el).attr("rel")
    $("#"+idFromRel)

  applyErrorValues: (el, data)->
    fieldsRow = @relatedRow(el)

    $.each data, (item)=>
      field = $(fieldsRow).find($("input[name='#{@modelPrefix}[#{data.id}][#{item}]']"))
      $(field).val(data[item])

      # Apply Any Client-side formatting for fields
      if field.hasClass("datepicker")
        DatePicker.setup(field)

  enableEditForRow: (row)->
    return if @editing

    fieldsRow = @relatedRow(row)

    @originalFields = fieldsRow.clone(true)

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
      $(row).replaceWith(context.originalFields)
      context.originalFields = null
      context.editing = false

