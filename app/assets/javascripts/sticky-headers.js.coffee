$ ->
  stick_points = []
  stick_heights = []
  left = $('.l-main').offset().left
  width = $('.l-main').outerWidth()

  affix = (index, scroll_point) ->
    stickable = $('.stickable')[index]
    height = 0
    i = 0
    while i < index
      height += stick_heights[i]
      i++
      if window.innerHeight >= 768 || i == 0
        if find_scrolly() >= scroll_point - height
          $(stickable).addClass('js-fixed').css({
              'top': height,
              'left': left,
              'width': width,
          })
        else
          $(stickable).removeClass('js-fixed').css({'top': "", 'left': "", 'width':""})
      else
        $(stickable).removeClass('js-fixed').css({'top': "", 'left': "", 'width':""})

  find_scrolly  = ->
    if window.pageYOffset != undefined
      return window.pageYOffset 
    else
      return (document.documentElement || document.body.parentNode || document.body).scrollTop

  stick_absolutely = (i, e, width, left) ->
    $('<div class="teflon"></div>').insertAfter(e)
    if !$(e).parent().hasClass('l-main') && $(e).parent().attr('id') != "sold-items"
      $(e).parent().css('overflow', 'hidden')
    $(e).addClass('js-positioned').next().css({
        'position': 'relative',
        'height': "+=" + stick_heights[i] + "px",
        'overflow': 'hidden'
      })

  clone_header_attr = (original, prime, current, last) ->
    if current == last - 1
      $(prime).attr('class', original.getAttribute('class'))
    else
      $(prime).css({
        'width': $(original).width(),
        }).attr('class', original.getAttribute('class'))

  stick_table = (index, sticky) ->
    $sticky = $(sticky).removeClass('stickable')
    $stuck = $sticky.clone()
    if $sticky.parent().hasClass('sortable')
      $stuck.addClass('sortable')
    $original_headers = $sticky.find('th')
    $prime_headers = $stuck.find('th')
    $prime_headers.each((i, e) ->
       clone_header_attr($original_headers[i], e, i, $original_headers.length)
      )
    $stuck.insertBefore($sticky.parent())
    $stuck.wrap('<table class="js-sticky stickable"></table>')
    $stuck.parent().css('width', $sticky.parent().width())
    $stuck.find('.select-all').click ->
      $sticky.find('.select-all').trigger "click"
    $stuck.find('th').click (e) ->
      return if $(e.target).is("input")
      i = e.target.cellIndex
      original = $sticky.find('th')[i]
      $(original).trigger "click"
      window.setTimeout ->
         clone_header_attr($original_headers[i], e, i, $original_headers.length)
        , 5

  measure_stickables = ->
    width = $('.l-main').outerWidth()
    left = $('.l-main').offset().left
    $('.stickable').each (i, e) ->
      stick_points.push($(e).offset().top)
      if $(e).prev('.nav--admin').length
        stick_heights.push($(e).outerHeight()-20)
      else
        stick_heights.push($(e).outerHeight())
      $(e).attr({'data-height': stick_heights[i], 'data-offset': stick_points[i]})
      if e.tagName != "THEAD"
        stick_absolutely(i, e)
      else
        stick_table(i, e)
    $('body').attr({'data-points': stick_points, 'data-heights': stick_heights})

  $(window).resize ->
    measure_stickables

  measure_stickables()

  $(window).scroll (event) ->
    affix i, point for point, i in stick_points

  $(window).trigger "scroll"

