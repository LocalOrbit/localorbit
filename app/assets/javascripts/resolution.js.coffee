find_orientation = ->
  if window.innerWidth < window.innerHeight
    "portrait"
  else if window.innerWidth > window.innerHeight
    "landscape"
  else
    "square"

set_viewport = ->
  viewport = document.getElementById('viewport')
  if $('body').hasClass('request-desktop')
    viewport.setAttribute("content", "width=960, initial-scale=1.0");
    $('#viewport-declarations').text("@-ms-viewport{ width: 960px; zoom: 1.0}\n@-o-viewport{ width: 960px; zoom: 1.0}\n@viewport{ width: 960px; zoom: 1.0}")

$('.toggle-viewport').click ->
  $('body').addClass('request-desktop')
  document.cookie = "request_desktop=true; path=/";
  set_viewport()

$(window).on "rotate, resize", ->
  set_viewport()

$(document).ready ->
  set_viewport()
