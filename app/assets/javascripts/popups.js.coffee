$ ->
  # Attaches to links with the '.popup-toggle' class and
  # shows/hides an element with the class indicated by the
  # data-popup attribute on the link.
  find_scrolly  = ->
    if window.pageYOffset != undefined
      return window.pageYOffset 
    else
      return (document.documentElement || document.body.parentNode || document.body).scrollTop

  clone_popup = ($element, toggle) ->
    if $('.l-main').outerWidth() <= 640
      styles = {
        position: 'fixed',
        top: 54
      }
      $element.find('div.datepicker').show()
    else
      styles = {
        'left': $element.offset().left,
        'top':  $element.offset().top
      }
    if $element.outerHeight() + 54 + find_scrolly() >= screen.height
      $('body').css('min-height', $element.outerHeight() + 74 + find_scrolly())
      styles.position = 'absolute'
      styles.top = find_scrolly() + 74 
    $element.css(styles).insertAfter('.overlay')

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
    if $element.parents('.product').length
      $('.overlay').addClass('mobile-dim')
    if $element.hasClass('popup--edit')
      $('.overlay').addClass('is-editable')
    position_popup($element)
    clone_popup($element, e.target)


  $('.modal-toggle').click ->
    destination = $(this).data('modal')
    $element = $("##{destination}")
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open is-dim is-modal')
    if $element.hasClass('clonable')
      clone_popup($element, this)

  $('.remote-modal-toggle').click (event)->
    event.preventDefault()
    href = $(this).attr("href")
    destination = $(this).data('modal')
    $element = $("##{destination}")
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open is-dim is-modal')
    $.get href, (response) =>
      $element.find(".popup-body").html(response)

  $('.popup button.close').click ->
    $popup = $(this).closest('.popup')
    $popup.addClass('is-hidden').css({'left': 'auto', 'top': 'auto'}).insertAfter('.popup-toggle[href="#' + $popup.attr('id') + '"]')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim')
    $('body').css('min-height', '0')

  $('.popup form[data-remote]').on 'ajax:success', (event, xhr, status) ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim')
