$ ->
  # Attaches to links with the '.popup-toggle' class and
  # shows/hides an element with the class indicated by the
  # data-popup attribute on the link.
  position_popup = ($element) ->
    bottom = $element.offset().top + $element.outerHeight()
    right = $element.offset().left + $element.outerWidth()
    if bottom > $('.l-app-footer').offset().top
      $element.removeClass('top-anchor').addClass('bottom-anchor')
    if right >= window.innerWidth
      $element.addClass('rtl')

  $('.popup-toggle').click (e) ->
    e.preventDefault()
    $element = $(this.hash)
    $element.toggleClass('is-hidden')
    $(".popup").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open')
    if $element.hasClass('popup--edit')
      $('.overlay').addClass('is-editable')
    position_popup($element)


  $('.modal-toggle').click ->
    destination = $(this).data('modal')
    $element = $(".#{destination}")
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open is-dim is-modal')

  $('.popup button.close').click ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable')

  $('.popup form[data-remote]').on 'ajax:success', (event, xhr, status) ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable')
