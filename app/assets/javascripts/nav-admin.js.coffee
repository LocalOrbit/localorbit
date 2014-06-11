$ -> 
  $('.nav--admin .caretted').click (e) ->
    e.preventDefault()
    $('.dropdown').not($(e.target).next()).parent().removeClass('is-open')
    $(e.target).parent().toggleClass('is-open')
    if $('.is-open > .caretted + .dropdown').length
      $('.overlay').addClass('is-open')
    else
      $('.overlay').removeClass('is-open')

  $('.nav-admin-toggle').click (e) ->
    e.preventDefault()
    $('#admin-nav').toggleClass('is-open')
