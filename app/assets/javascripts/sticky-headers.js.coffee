$ ->
  app_header = $(".l-app-header").height()
  $(".l-app-header").addClass('js-positioned')
  $('body').css('padding-top', app_header).find('.l-app-header')
