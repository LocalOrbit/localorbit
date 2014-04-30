$ ->
  app_header = $(".l-app-header").height()
  $("body").css("padding-top", app_header)
  $(".l-app-header").addClass("js-positioned")
  sub_header = $('.sticky-table-header').length > 0 ? true : false


  stick_tables = ->
    $sticky = $('thead.sticky')
    $stuck  = $sticky.clone().removeClass('sticky').addClass('stuck')
    $stuck.find('th').each((i, e) ->
        original_th = $sticky.find('th')[i]
        $(e).css('width', $(original_th).width()) 
  
  stick_tabs = ->
    $tab_header = $(".tab-header")
    absolute_top = $tab_header.offset().top - app_header - 10

    $tab_header.next().css("margin-top", $tab_header.height() + 50);
    $tab_header.addClass("js-positioned").css('top', absolute_top)

    find_scrolly  = ->
      if window.pageYOffset != undefined
        return window.pageYOffset 
      else
        return (document.documentElement || document.body.parentNode || document.body).scrollTop

    if sub_header
      $sub_header = $(".sticky-table-header")
      sub_top = $tab_header.height() + app_header - 30 
      $sub_header.parent().css({"padding-top": $sub_header.height(), "position": "relative"});
      $sub_header.addClass("js-positioned").css('top', 0)

    $(window).scroll ->
      if absolute_top <= find_scrolly()
        $tab_header.addClass('js-fixed').css('top', app_header)
      else
        $tab_header.removeClass('js-fixed').css('top', absolute_top)

      if sub_header
        if sub_top <= find_scrolly()
          $sub_header.addClass('js-fixed').css('top', sub_top)
        else
          $sub_header.removeClass('js-fixed').css('top', 0)


  return unless $('.tab-header').length
  stick_tabs()

