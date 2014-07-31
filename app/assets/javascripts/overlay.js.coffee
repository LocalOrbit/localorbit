close_popups = ->
  $('.overlay + .popup').each (i,e) ->
    if $('.popup-toggle[href="#' + e.id + '"]').length
      toggle = '.popup-toggle[href="#' + e.id + '"]'
    else
      toggle = '.modal-toggle[data-modal="' + e.id + '"]'
    $(e).remove().insertAfter(toggle)
      .css({'position': "", 'left': "", 'top': ""})
  $('.popover, .popup, .dropdown').addClass('is-hidden')
  $('body').css('min-height', '0')

$('.overlay').on "click", (e) ->
  $('.is-open').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim')
  close_popups()
    

$(window).keyup (e) ->
  if e.keyCode == 27 && $('.overlay.is-open').length
    $('.is-open').removeClass('is-open is-dim is-modal is-editable mobile-dim')
    close_popups()

