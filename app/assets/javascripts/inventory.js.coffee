$ ->
  return unless $("#inventory_table").length
  newFormAction = $("#new_lot").attr('action')
  errorPayload = $("#inventory_table").data("error-payload")

  editableRow = null
  hiddenRow = null
  originalRowState = null

  disableFields = (sel)->
    $(sel).each ()->
      $(this).attr("readonly", true)
      $(this).attr("disabled", true)

  enableFields = (sel)->
    $(sel).each ()->
      $(this).removeAttr("readonly")
      $(this).removeAttr("disabled")

  setFormActionAndMethod = (action, method)->
    form = $("#new_lot")
    form.attr('action', action)

    if method.toLowerCase() == "put"
      methodField = $('<input name="_method" type="hidden" value="put">')
      $("#new_lot").append(methodField)
    else
      $("[name=_method]").remove()

  applyErrorValues = (id, data)->
    fieldsRow = $("#fields_#{hiddenRow.attr('id')}")
    $.each data, (item) ->
      field = $(fieldsRow).find("#lot_#{id}_#{item}")
      field.val(errorPayload[item])
      if field.hasClass("datepicker")
        DatePicker.setup(field)

  enableEditForRow = (id)->
    return if editableRow
    hiddenRow = $("#lot_#{id}")
    fieldsRow = $("#fields_#{hiddenRow.attr('id')}")

    originalRowState = $(fieldsRow).clone(true)
    action = fieldsRow.data('form-url')

    setFormActionAndMethod(action, "put")

    disableFields("#inventory_table thead tr.lot input")
    enableFields($(fieldsRow).find("input"))

    $(hiddenRow).hide()
    $(fieldsRow).show()
    editableRow = fieldsRow


  if errorPayload
    enableEditForRow(errorPayload.id)
    applyErrorValues(errorPayload.id, errorPayload)

  # Events
  $("#inventory_table tbody tr.lot").on "click", ()->
    if $(this).hasClass('fields_lot')
      return

    enableEditForRow($(this).attr('id').replace(/lot_/, ""))

  $("#inventory_table tbody").on "click", 'tr.fields_lot .cancel', ()->
    # get the first 'tr' parent
    row = $(this).parents("tr")[0]

    enableFields("#inventory_table thead tr.lot input")

    setFormActionAndMethod(newFormAction, "post")

    $(hiddenRow).show()
    hiddenRow = null

    disableFields($(row).find("input"))
    $(row).hide()
    $(row).replaceWith(originalRowState)
    originalRowState = null
    editableRow = null
