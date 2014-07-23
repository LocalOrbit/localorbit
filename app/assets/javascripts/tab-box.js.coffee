$ ->
  return unless $('.tab-box').length

  $('.tab-box').each (i, box) ->
    tabs_height = $(box).find('.tabs').height() + 10
    items_height = 0

    $(box).children('.tabbed-item').each (i, item) ->
      height = $(item).height()
      if $(item).find("#seller-map").length
        if $('#seller-map').height() < 20
          height = height + ($(item).width() * .625)
      if height > items_height
        items_height = height
    $(box).css('height': tabs_height + items_height).addClass('js-sized').children('.tabbed-item').css({'height': items_height, 'top': tabs_height})

  $('.tab-box .tab > a').click (e) ->
    e.preventDefault()
    $container = $(this).closest('.tab-box')
    $(this).removeClass('inactive').addClass('active')
    $container.find('.tabs a').not(this).removeClass('active').addClass('inactive')

    $(e.target.hash).addClass('active')
    $container.find('.tabbed-item').not(e.target.hash).removeClass('active')
