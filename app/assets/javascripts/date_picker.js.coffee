class @DatePicker
  @format: 'dd M yy'
  @setup: (field) ->
    field = $(field)

    options = {dateFormat: @format}
    options.minDate = field.data('min-date')
    options.maxDate = field.data('max-date')
    if field.is('div')
      options.onSelect = ->
        field.slideUp()
      options.altField = "#" + field.attr('data-input')
      field.find('.ui-datepicker-inline').attr('style', null)

    picker = field.datepicker(options)

    if field.val()
      # JS parses "2014-02-15" different than "2014/02/15"
      date_str = field.val().replace(/-/g, "/")
      if date_str.match(/T/)
        length = date_str.indexOf('T')
        date_str = date_str.substr(0,length)
      else
        date_str = date_str.substr(0,11)
      picker.datepicker('setDate', new Date(date_str))

    if field.is('div')
      field.hide()
      $('#' + field.attr('data-input')).click (e) ->
        $('div.datepicker').not(field).slideUp()
        field.slideDown()
      $('#' + field.attr('data-input')).prop('readonly', true)
    field.prop('readonly', true)
    field.change (e) ->
      field.datepicker('setDate', new Date(field.val()))

    @appendClearLink(field)



  @appendClearLink: (field)->
    clearLink = $("<button class='clear-link'><i class='font-icon icon-clear'></i></button>")

    if field.is('input')
      field.after(clearLink)
    else
      $('#' + field.attr('data-input')).after(clearLink)
    clearLink.on 'click', (event)->
      event.preventDefault()
      field.val('')

  $ ->
    $(".datepicker").each (idx, field)->
      DatePicker.setup(field)
