$ ->
  dateFormat = 'D, dd M yy'

  $(".datepicker").each (idx, field)->
    field = $(field)

    options = {dateFormat: dateFormat}
    options.minDate = field.data('min-date')
    options.maxDate = field.data('max-date')

    field.datepicker(options)
    field.prop('readonly', true)
