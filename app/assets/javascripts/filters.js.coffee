$ ->
  $('.filter-toggle').click (e) ->
    e.preventDefault()
    $('.filter-toggle').not(this).removeClass('is-open')
    $('.filter-list').not($(this.hash)).removeClass('is-open')
    $(this).toggleClass('is-open')
    $(this.hash).toggleClass('is-open')
    if $('.filter-toggle.is-open').length
      $('.overlay').addClass('is-open')
    else
      $('.overlay').removeClass('is-open')

  $('.filter-dropdown').change ->
    value = $(this).val()
    key = $(this).data("parameter")

    params = parseSearchString()
    if value == "0" || value == ""
      delete params[key]
    else
      params[key] = value

    window.location.search = $.param(params)



  parseSearchString = () ->
    list = window.location.search.substr(1).split("&")
    params = {}
    for param in list
      tokens = param.split("=")
      if tokens.length == 2
        params[tokens[0]] = tokens[1]

    params
