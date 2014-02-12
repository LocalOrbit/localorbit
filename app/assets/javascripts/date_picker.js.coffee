$ ->
  dateFormat = 'D, dd M yy'

  $(".datepicker").each (idx, field)->
    field = $(field)

    options = {dateFormat: dateFormat}
    options.minDate = field.data('min-date')
    options.maxDate = field.data('max-date')

    picker = field.datepicker(options)
    if field.val()
      # JS parses "2014-02-15" different than "2014/02/15"
      date_str = field.val().substr(0,10).replace(/-/g, "/")
      picker.datepicker('setDate', new Date(date_str))

    field.prop('readonly', true)

    clearLink = $("<a href='javascript:void(0)'>x</a>")
    field.after(clearLink)
    clearLink.on 'click', ()->
      field.val('')

