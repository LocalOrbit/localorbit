$ ->
  dateFormat = 'D, dd M yy'

  $(".datepicker").each (idx, field)->
    field = $(field)

    options = {dateFormat: dateFormat}
    options.minDate = field.data('min-date')
    options.maxDate = field.data('max-date')

    picker = field.datepicker(options)
    picker.datepicker('setDate', Date.parse(field.val())) if field.val()

    field.prop('readonly', true)

    clearLink = $("<a href='javascript:void(0)'>x</a>")
    field.after(clearLink)
    clearLink.on 'click', ()->
      field.val('')

