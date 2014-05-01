$ ->
  stick_points = []
  stick_heights = []

  affix = (index, scroll_point) ->
    stickable = $('.stickable')[index]
    height = 0
    i = 0
    while i < index
      height += stick_heights[i]
      i++
    if find_scrolly() >= scroll_point - height
      $(stickable).addClass('js-fixed').css({'top': height})
    else
      $(stickable).removeClass('js-fixed').css({'top': ""})

  find_scrolly  = ->
    if window.pageYOffset != undefined
      return window.pageYOffset 
    else
      return (document.documentElement || document.body.parentNode || document.body).scrollTop

  stick_absolutely = (i, e) ->
    $(e).addClass('js-positioned').next().css({
        'position': 'relative',
        'margin-top': "+=" + stick_heights[i] + "px",
        'overflow': 'hidden'
      })

  stick_table = (index, sticky) ->
    $sticky = $(sticky).removeClass('stickable')
    $stuck = $sticky.clone()
    $stuck.find('th').each((i, e) ->
        original_th = $sticky.find('th')[i]
        $(e).css({
          'width': $(original_th).width(),
          'max-width': $(original_th).width()
          })
      )
    $stuck.insertBefore($sticky.parent())
    $stuck.wrap('<table class="js-sticky stickable"></table>')
    $stuck.parent().css('width', $sticky.parent().width())
    $stuck.find('.select-all').click ->
      $sticky.find('.select-all').trigger "click"

  $('.stickable').each (i, e) ->
    stick_points.push($(e).offset().top)
    stick_heights.push($(e).outerHeight())
    $(e).attr({'data-height': stick_heights[i], 'data-offset': stick_points[i]})
    if e.tagName != "THEAD"
      stick_absolutely(i, e)
    else
      stick_table(i, e)

  $(window).scroll (event) ->
    affix i, point for point, i in stick_points

  $(window).trigger "scroll"
