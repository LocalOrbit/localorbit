$ ->
  $('.mobile-toggle').click (e) ->
    $('.mobile-toggle[href="' + e.target.hash + '"]').toggleClass('is-hidden')
    $(e.target.hash).toggleClass('hidden-mobile')
  $('.filter-toggle').click (e) ->
    e.preventDefault()
    $('.filter-toggle').not(this).removeClass('is-open')
    $('.filter-list').not($(this.hash)).removeClass('is-open')
    $(this).toggleClass('is-open')
    $(this.hash).toggleClass('is-open')
    if $('.filter-toggle.is-open').length
      $('.overlay').addClass('is-open hidden-mobile')
    else
      $('.overlay').removeClass('is-open hidden-mobile')

  $('.filter-dropdown').change ->
    value = $(this).val()
    key = $(this).data("parameter")
    addQueryStringParameter(key, value)

  $("#search-btn").click (e) ->
    e.preventDefault()
    addQueryStringParameter "search", $("#search").val()

  $("#search").keypress (e) ->
    if (e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)
      $("#search-btn").click()

  $('#submit_send_selected').click ->
    $('#invoice-list').trigger('submit')

  parseSearchString = () ->
    list = window.location.search.substr(1).split("&")
    params = {}
    for param in list
      tokens = param.split("=")
      if tokens.length == 2
        params[tokens[0]] = tokens[1]

    params

  addQueryStringParameter = (key, value) ->
    params = parseSearchString()
    params[key] = value

    window.location.search = $.param(params)

  # Ransack inputs
  $(".filter-input").change ->
    $(this).parents("form").first().submit()

  $(".per-page-filter").change ->
    window.location.href = $(this).val()

