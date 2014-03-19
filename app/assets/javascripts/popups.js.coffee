$ ->
  # Attaches to links with the '.popup-toggle' class and
  # shows/hides an element with the class indicated by the
  # data-popup attribute on the link.
  $('.popup-toggle').click (e) ->
    e.preventDefault()
    $element = $(this.hash)
    $element.toggleClass('is-hidden')
    $(".popup").not($element).addClass('is-hidden')
    if $(".popup").not(".is-hidden").length
      $('.overlay').addClass('is-open');
    else
      $('.overlay').addClass('is-open');


  $('.modal-toggle').click ->
    destination = $(this).data('modal')
    $element = $(".#{destination}")
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    if $(".popup").not(".is-hidden").length
      $('.overlay').addClass('is-open is-dim is-modal');
    else
      $('.overlay').addClass('is-open is-dim is-modal');

  $('.popup .popup-header button').click ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dim is-modal');
