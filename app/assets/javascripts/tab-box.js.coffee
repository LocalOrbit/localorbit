$ ->
  return unless $('.tab-box').length

  $('.tab-box').each (i, box) ->
    tabs_height = $(box).find('.tabs').height() + 10

    $(box).children('.tabbed-item').each (i, item) ->
      gross_height = $(item).height() + tabs_height
      $(item).css('margin-top', tabs_height)
      if gross_height> $(box).height()
        $(box).css('height', gross_height)
    $(box).children('.tabbed-item').css('height', $(box).height() - tabs_height)

  $('.tab-box .tab > a').click (e) ->
    e.preventDefault()
    $container = $(this).closest('.tab-box')
    $(this).removeClass('inactive').addClass('active')
    $container.find('a').not(this).removeClass('active').addClass('inactive')

    $(e.target.hash).addClass('active')
    $container.find('.tabbed-item').not(e.target.hash).removeClass('active')
