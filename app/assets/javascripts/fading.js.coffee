$ ->
  sandbox = document.createElement('div')
  features = {}

  detect_transitions = ->
    ext = false
    styles = ["t", "msT", "OT", "WebkitT", "MozT"]
    events = ["transitionend", "transitionend", "oTransitionEnd", "webkitTransitionEnd", "transitionend"]

    for p in styles
      ext = events.shift()
      if sandbox.style[ p + "ransition"] != undefined
        $('body').addClass('transitions')
        features.transitions = ext
        break

  detect_transitions()

  if $('body').hasClass('transitions')
    $('.flash').addClass('is-fading')
    $('.flash').on features.transitions, (e) ->
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

