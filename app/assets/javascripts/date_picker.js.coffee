class @DatePicker
  @format: 'dd M yy'
  @setup: (field) ->
    field = $(field)

    options = {dateFormat: @format}
    options.minDate = field.data('min-date')
    options.maxDate = field.data('max-date')
    if field.parent().hasClass('alt-datepicker')
      options.beforeShow = ->
        field.parent().addClass('datepicker-is-open')
        $('body').addClass('datepicker-no-float')
      options.onClose = ->
        field.parent().removeClass('datepicker-is-open')
        $('body').removeClass('datepicker-no-float')


    picker = field.datepicker(options)

    if field.val()
      # JS parses "2014-02-15" different than "2014/02/15"
      date_str = field.val().substr(0,10).replace(/-/g, "/")
      picker.datepicker('setDate', new Date(date_str))

    field.prop('readonly', true)

    @appendClearLink(field)

    if field.parent().hasClass('alt-datepicker')
      options.altField = "#" + field.attr('id')
      field.parent().datepicker(options)
      field.parent().find('.ui-datepicker-inline').attr('style', null)


  @appendClearLink: (field)->
    clearLink = $("<button class='clear-link'><i class='font-icon icon-clear'></i></button>")
    field.after(clearLink)
    clearLink.on 'click', (event)->
      event.preventDefault()
      field.val('')

$ ->
  $(".datepicker").each (idx, field)->
    DatePicker.setup(field)
