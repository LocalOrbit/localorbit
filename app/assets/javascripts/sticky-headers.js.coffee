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

  clone_header_attr = (original, prime) ->
    $(prime).css({
      'width': $(original).width(),
      }).attr('class', original.getAttribute('class'))
    
  
  stick_table = (index, sticky) ->
    $sticky = $(sticky).removeClass('stickable')
    $stuck = $sticky.clone()
    if $sticky.parent().hasClass('sortable')
      $stuck.addClass('sortable')
    $stuck.find('th').each((i, e) ->
       clone_header_attr($sticky.find('th')[i], e)
      )
    $stuck.insertBefore($sticky.parent())
    $stuck.wrap('<table class="js-sticky stickable"></table>')
    $stuck.parent().css('width', $sticky.parent().width())
    $stuck.find('.select-all').click ->
      $sticky.find('.select-all').trigger "click"
    $stuck.find('th').click (e) ->
      original = $sticky.find('th')[e.target.cellIndex]
      $(original).trigger "click"
      window.setTimeout ->
          $stuck.find('th').each (i, header) ->
            original = $sticky.find('th')[i]
            clone_header_attr(original, header)
        , 5


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
