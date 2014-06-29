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

  size_popup = ($popup) ->
    $popup.css('min-height', $(window).height() - $('.nav--app').outerHeight() - 20)

  $('.popup-toggle').click (e) ->
    e.preventDefault()
    $element = $(this.hash)
    $element.toggleClass('is-hidden')
    $(".popup").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open')
    if $element.hasClass('popup--edit')
      if screen.width <= 600
        size_popup($element)
      $('.overlay').addClass('is-editable')
    position_popup($element)


  $('.modal-toggle').click ->
    destination = $(this).data('modal')
    $element = $(".#{destination}")
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open is-dim is-modal')

  $('.remote-modal-toggle').click (event)->
    event.preventDefault()
    href = $(this).attr("href")
    destination = $(this).data('modal')
    $element = $(".#{destination}")
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open is-dim is-modal')
    $.get href, (response) =>
      $element.find(".popup-body").html(response)

  $('.popup button.close').click ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable')

  $('.popup form[data-remote]').on 'ajax:success', (event, xhr, status) ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable')
