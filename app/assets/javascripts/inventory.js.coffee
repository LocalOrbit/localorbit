class EditTable
  @build: (opts={})->
    table = new EditTable(opts={})
    table.bindActions()
    table

  constructor: ()->
    @selectedRow = null
    @hiddenRow = null
    @originalFields = null
    @editing = false
    @initialAction = $("#new_lot").attr('action')
    @errorPayload = $("#inventory_table").data("error-payload")

    if @errorPayload
      row = $("#lot_" + @errorPayload.id)
      @enableEditForRow(row)
      @applyErrorValues(row, @errorPayload)

  form: ()->
    $("#new_lot")

  hiddenPutMethod:  ()->
    $('<input name="_method" type="hidden" value="put">')

  headerFieldsRow: ()->
    $("#inventory_table thead tr.lot")

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
    @form().attr('action', action)

    if method.toLowerCase() == "put"
      @form().append(@hiddenPutMethod())
    else
      $("[name=_method]").remove()

  # TODO: Rename to applyModelValues
  applyErrorValues: (el, data)->
    # TODO: pull into a helper
    # TODO: Move fieldsRow to a rel tag
    fieldsRow = $("#fields_#{@hiddenRow.attr('id')}")
    $.each data, (item) ->
      id = "#lot_#{data.id}_#{item}"
      field = $(fieldsRow).find(id)
      field.val(data[item])
      if field.hasClass("datepicker")
        DatePicker.setup(field)

  enableEditForRow: (row)->
    return if @editing
    fieldsRowId = $(row).attr('rel')
    fieldsRow = $("#"+fieldsRowId)

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
    $("#inventory_table tbody tr.lot").on "click", ()->
      if $(this).hasClass('fields_lot')
        return

      context.enableEditForRow(this)

    $("#inventory_table tbody").on "click", 'tr.fields_lot .cancel', ()->
      # get the first 'tr' parent
      row = $(this).parents("tr")[0]
      context.enableFields("#inventory_table thead tr.lot")

      context.setFormActionAndMethod(context.initialAction, "post")

      $(context.hiddenRow).show()
      context.hiddenRow = null

      context.disableFields(row)
      $(row).hide()
      $(row).replaceWith(context.originalFields)
      context.originalFields = null
      context.editing = false

$ ->
  return unless $("#inventory_table").length
  editTable = EditTable.build()
