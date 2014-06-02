$ ->

  $('.table-wrapper').scroll (e) ->
    if e.target.scrollLeft == 0
      $(e.target).addClass('hard-left')
    else
      $(e.target).removeClass('hard-left')
      $(e.target).find('.fade-left').css('left', e.target.scrollLeft)

    if e.target.scrollLeft + $(e.target).width() == $(e.target).children('table').width()
      $(e.target).addClass('hard-right')
    else
      $(e.target).removeClass('hard-right')
      $(e.target).find('.fade-right').css('left', $(e.target).width() + e.target.scrollLeft - 20)

  $(document).ready ->
    $('.table-wrapper').prepend('<div class="fade-left"></div>')
    $('.table-wrapper').append('<div class="fade-right"></div>')
    $('.table-wrapper').trigger "scroll"

