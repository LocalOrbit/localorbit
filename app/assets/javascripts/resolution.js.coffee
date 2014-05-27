$ ->
  set_viewport = ->
    if window.innerWidth <= 960 && window.innerWidth < window.innerHeight
     document.getElementById("viewport").setAttribute("content", "width=960; initial-scale=0.5");   

  $(window).rotate ->
    set_viewport()

  set_viewport()
