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
    $('#toggle-mobile').removeClass('is-hidden')
  else
    viewport.setAttribute("content", "width=device-width, initial-scale=1.0");
    $('#viewport-declarations').text("@-ms-viewport{ width: device-width; zoom: 1.0}\n@-o-viewport{ width: device-width; zoom: 1.0}\n@viewport{ width: device-width; zoom: 1.0}")
    $('#toggle-mobile').addClass('is-hidden')


$('#toggle-desktop').click ->
  $('body').addClass('request-desktop')
  document.cookie = "request_desktop=true; path=/";
  set_viewport()

$('#toggle-mobile').click ->
  $('body').removeClass('request-desktop')
  document.cookie = "request_desktop=false; path=/";
  set_viewport()

$(window).on "rotate, resize", ->
  set_viewport()

$(document).ready ->
  set_viewport()
