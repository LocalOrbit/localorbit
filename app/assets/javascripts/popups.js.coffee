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
        top: 54,
        bottom: "auto",
      }
      $element.find('div.datepicker').show()
    else
      styles = {
        left: $element.offset().left,
        top:  $element.offset().top,
        bottom: "auto"
      }
    if $element.outerHeight() + 54 + find_scrolly() >= screen.height
      $('body').css('min-height', $element.outerHeight() + 74 + find_scrolly())
      styles.position = 'absolute'
      styles.top = find_scrolly() + 74
    $element.css(styles).insertAfter('.overlay')

  load_map = ($element) ->
    map = $element.find('.location-map').get(0)
    if map? and map.getAttribute('src') == "" and map.getAttribute('data-src') != ""
      map.src = map.getAttribute('data-src')

  position_popup = ($element) ->
    bottom = $element.offset().top + $element.outerHeight()
    right = $element.offset().left + $element.outerWidth()
    if bottom > $('.l-app-footer').offset().top
      $element.removeClass('top-anchor').addClass('bottom-anchor')
    if right >= window.innerWidth
      $element.addClass('rtl')

  $(document.body).on 'click', '.popup-toggle', (e) ->
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
    if !$element.hasClass('is-hidden')
      load_map($element)
    clone_popup($element, e.target)


  $(document.body).on 'click', '.modal-toggle', ->
    if this.tagName == "A"
      destination = this.hash
    else
      destination = "#" + this.getAttribute('data-modal')
    $element = $(destination)
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open is-dim is-modal')
    if $element.hasClass('clonable')
      clone_popup($element, this)

  $(document.body).on 'click', '.remote-modal-toggle', (event)->
    event.preventDefault()
    href = this.href
    destination = $(this).data('modal')
    $element = $("##{destination}")
    $element.toggleClass('is-hidden')
    $(".modal").not($element).addClass('is-hidden')
    $('.overlay').addClass('is-open is-dim is-modal')
    $.get href, (response) =>
      $element.find(".popup-body").html(response)

  $(document.body).on "click touchend", '.popup button.close', (e) ->
    $popup = $(this).closest('.popup')
    $popup.addClass('is-hidden').css({'left': '', 'top': '', 'position': ''}).insertAfter('.popup-toggle[href="#' + $popup.attr('id') + '"]')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim')
    $('body').css('min-height', '0')

  $(document.body).on 'ajax:success', '.popup form[data-remote]', (event, xhr, status) ->
    $(this).closest('.popup').addClass('is-hidden')
    $('.overlay').removeClass('is-open is-dark is-dim is-modal is-editable mobile-dim')
