$ ->
  sandbox = document.createElement('div')
  features = {}

  detect_transitions = ->
    ext = false
    styles = ["t", "msT", "OT", "WebkitT", "MozT"]
    events = ["transitionend", "transitionend", "oTransitionEnd", "webkitTransitionEnd", "transitionend"]

    for p in styles
      if sandbox.style[ p + "ransition"] != undefined
        ext = events[p]
        $('body').addClass('transitions')
        break

      features.transitions = ext

  detect_transitions()

  if $('body').hasClass('transitions')
    $('.flash').addClass('is-fading')
    $('.flash').on features.transitions, (e) ->
      e.target.remove()
  else
    window.setTimeout ->
        $('.flash').fadeOut(500)
      , 3000

