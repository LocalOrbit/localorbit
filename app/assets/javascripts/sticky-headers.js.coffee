$ ->
  return unless $('.tab-header').length
  app_header = $(".l-app-header").height()
  $tab_header = $(".tab-header")
  absolute_top = $tab_header.offset().top - app_header - 20
  $("body").css("padding-top", app_header)
  $(".l-app-header").addClass("js-positioned")

  $tab_header.next().css("margin-top", $tab_header.height() + 50);
  $tab_header.addClass("js-positioned").css('top', absolute_top)

  find_scrolly  = ->
    if window.pageYOffset != undefined
      return window.pageYOffset 
    else
      return (document.documentElement || document.body.parentNode || document.body).scrollTop

  $(window).scroll ->
    if absolute_top <= find_scrolly()
      $tab_header.addClass('js-fixed').css('top', app_header)
    else
      $tab_header.removeClass('js-fixed').css('top', absolute_top)

