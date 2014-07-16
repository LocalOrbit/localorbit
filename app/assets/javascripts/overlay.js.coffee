close_popups = ->
  $('.overlay + .popup').each (i,e) ->
    $(e).remove().insertAfter('.popup-toggle[href="#' + e.id + '"]')
      .css({'left': 'auto', 'top': 'auto'})
  $('.popover, .popup, .dropdown').addClass('is-hidden')

$('.overlay').click (e) ->
  $('.is-open').removeClass('is-open is-dark is-dim is-modal is-editable')
  close_popups()
    

$(window).keyup (e) ->
  if e.keyCode == 27 && $('.overlay.is-open').length
    $('.is-open').removeClass('is-open is-dim is-modal is-editable')
    close_popups()

