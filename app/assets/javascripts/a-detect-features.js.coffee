$ ->
  sandbox = document.createElement('div')
  window.features = {}

  detect_form_attribute = ->
    bucket = document.createElement('input')
    bucket.setAttribute('form', 'sandbox_form')
    sandbox_form = document.createElement('form')
    sandbox_form.setAttribute('id', 'sandbox_form')
    console.log bucket.form

  window.detect_input_date = ->
    bucket = document.createElement('input')
    bucket.setAttribute('type', 'date')
    if bucket.type != "text"
      $('body').addClass('input_date')
      features.input_date = true
    else
      features.input_date = false

  window.detect_touch = ->
    if window.ontouchstart == null || window.onmsgesturechange == null
      features.touch = true
      $('body').addClass('touch')
    else
      features.touch = false
      $('body').addClass('no-touch')


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
  detect_touch()
  detect_form_attribute()
