$ ->
  # Attaches to links with the '.popup-toggle' class and
  # shows/hides an element with the class indicated by the
  # data-popup attribute on the link.
  $('.popup-toggle').click ->
    destination = $(this).data('popup')
    $element = $(this).parent().find(".#{destination}")
    $element.toggleClass('is-hidden')
    $(".popup").not($element).addClass('is-hidden')

  $('.popup .popup-header button').click ->
    $(this).closest('.popup').addClass('is-hidden')
