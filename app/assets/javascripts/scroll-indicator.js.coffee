$ ->

  $('.table-wrapper').scroll (e) ->
    $wrapper = $(e.target.parentNode);
    if e.target.scrollLeft == 0
      $wrapper.addClass('hard-left')
    else
      $wrapper.removeClass('hard-left')

    if e.target.scrollLeft + $(e.target).width() == $(e.target).children('table').width()
      $wrapper.addClass('hard-right')
    else
      $wrapper.removeClass('hard-right')

  $(document).ready ->
    $('.table-wrapper').wrap('<div class="scroll-wrapper"/>')
    $('.scroll-wrapper').prepend('<div class="fade-left"></div>')
    $('.scroll-wrapper').append('<div class="fade-right"></div>')
    $('.table-wrapper').trigger "scroll"

  $(window).on "rotate", ->
    $('.table-wrapper').trigger "scroll"
    
