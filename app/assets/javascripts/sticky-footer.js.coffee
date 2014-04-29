$ ->
  glue_footer = ->
    $('.l-main').css('min-height', $(window).height() - ($('.l-app-header').outerHeight() + $('.l-app-footer').outerHeight()))

  $(window).resize ->
    glue_footer()

  glue_footer()
