$ ->
  find_orientation = ->
    orientation = "square"
    if window.innerWidth < window.innerHeight
      orientation = "portrait"
    if window.innerWidth > window.innerHeight
      orientation = "landscape"

  set_viewport = ->
    if window.innerWidth <= 767 && find_orientation() == "landscape"
      document.getElementById("viewport").setAttribute("content", "width=960, initial-scale=1.0");   
    else if window.innerWidth <=767 
      document.getElementById("viewport").setAttribute("content", "width=device-width, initial-scale=1.0");   

  $(window).on "rotate, resize", ->
    set_viewport()

  $(document).ready ->
    set_viewport()
