$ ->
  sandbox = document.createElement('div')
  window.features = {}

  window.detect_input_date = ->
    bucket = document.createElement('input')
    bucket.setAttribute('type', 'date')
    if bucket.type != "text"
      $('body').addClass('input_date')
      features.input_date = true
    else
      features.input_date = false

  window.detect_transforms = ->
    ext = false
    styles = ["t", "msT", "OT", "WebkitT", "MozT"]
    for p in styles
      if sandbox.style[ p + "ransform"] != undefined
        $('body').addClass('transforms')
        features.transforms = true
        break

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

  detect_transforms()
  detect_transitions()
  detect_input_date()
