$ ->
  sandbox = document.createElement('div')
  window.features = {}

  window.detect_transitions = ->
    ext = false
    styles = ["t", "msT", "OT", "WebkitT", "MozT"]
    events = ["transitionend", "transitionend", "oTransitionEnd", "webkitTransitionEnd", "transitionend"]

    for p in styles
      ext = events.shift()
      if sandbox.style[ p + "ransition"] != undefined
        $('body').addClass('transitions')
        features.transitions = ext
        break

  window.fade_flash = ->
    if $('body').hasClass('transitions')
      $('.flash').addClass('is-fading')
      $('.flash').on window.features.transitions, (e) ->
        $(e.target).remove()

      $('.toggle-slide').on 'click', (e) ->
        e.preventDefault()
        $(e.target.hash).toggleClass('is-up')

    else
      $('.toggle-slide').on 'click', (e) ->
        e.preventDefault()
        $(e.target.hash).toggleClass('is-up').slide()

      window.setTimeout ->
          $('.flash').fadeOut(500)
        , 3000

  window.detect_transitions()
  window.fade_flash()
