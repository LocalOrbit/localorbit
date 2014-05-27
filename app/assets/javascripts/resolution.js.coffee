$ ->
  set_viewport = ->
    if window.innerWidth <= 960 && window.innerWidth < window.innerHeight
     document.getElementById("viewport").setAttribute("content", "width=960");   

  $(window).on "rotate, resize", ->
    set_viewport()

  $(document).ready ->
    set_viewport()
