$ ->
  # Attaches to links with the '.popup-toggle' class and
  # shows/hides an element with the id indicated by the
  # link's href
  $('.popup-toggle').click (e) ->
    e.preventDefault()
    $element = $(this.hash)
    $element.toggleClass('is-hidden')
    $(".popup").not($element).addClass('is-hidden')

  $('.popup .popup-header button').click ->
    $(this).closest('.popup').addClass('is-hidden')
