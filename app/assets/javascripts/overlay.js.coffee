$('.overlay').click (e) ->
  $('.is-open').removeClass('is-open is-dark is-dim is-modal is-editable')
  $('.popover, .popup, .dropdown').addClass('is-hidden')

$(window).keyup (e) ->
  if e.keyCode == 27 && $('.overlay.is-open').length
    $('.is-open').removeClass('is-open is-dim is-modal is-editable')
    $('.popover, .popup, .dropdown').addClass('is-hidden')

