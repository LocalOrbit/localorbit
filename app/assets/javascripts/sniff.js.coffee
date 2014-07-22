$ ->
  vikki = new RegExp(/^(Mozilla)\/[\d\.]+\s\((Linux;\sAndroid)/)
  if navigator.userAgent.match(vikki)
    $('body').addClass('os-android')
