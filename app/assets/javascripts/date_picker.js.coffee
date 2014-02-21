class @DatePicker
  @format: 'D, dd M yy'
  @setup: (field) ->
    field = $(field)

    options = {dateFormat: @format}
    options.minDate = field.data('min-date')
    options.maxDate = field.data('max-date')

    picker = field.datepicker(options)
    if field.val()
      # JS parses "2014-02-15" different than "2014/02/15"
      date_str = field.val().substr(0,10).replace(/-/g, "/")
      picker.datepicker('setDate', new Date(date_str))

    field.prop('readonly', true)

    unless field.siblings(".clear-link").length
      @appendClearLink(field)

  @appendClearLink: (field)->
    clearLink = $("<a href='#' class='clear-link'>x</a>")
    field.after(clearLink)
    clearLink.on 'click', (event)->
      event.preventDefault()
      field.val('')

$ ->
  $(".datepicker").each (idx, field)->
    DatePicker.setup(field)
