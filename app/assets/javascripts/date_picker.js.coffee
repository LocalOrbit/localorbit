class @DatePicker
  @format: 'dd M yy'
  @setup: (field) ->
    field = $(field)

    options = {dateFormat: @format}
    options.minDate = field.data('min-date')
    options.maxDate = field.data('max-date')
    if field.is('div')
      options.beforeShow = ->
        field.addClass('datepicker-is-open')
        $('body').addClass('datepicker-no-float')
      options.onClose = ->
        field.removeClass('datepicker-is-open')
        $('body').removeClass('datepicker-no-float')
      options.altField = "#" + field.attr('data-input')
      field.find('.ui-datepicker-inline').attr('style', null)

    picker = field.datepicker(options)

    if field.val()
      # JS parses "2014-02-15" different than "2014/02/15"
      date_str = field.val().substr(0,12).replace(/-/g, "/")
      picker.datepicker('setDate', new Date(date_str))

    if field.is('div')
      field.hide()
      $('#' + field.attr('data-input')).click (e) ->
        field.slideDown()
    field.prop('readonly', true)

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
