$ ->
  return unless $('.tab-box').length

  $('.tab-box .tab > a').click (e) ->
    e.preventDefault()
    $container = $(this).closest('.tab-box')
    $(this).removeClass('inactive')
    $container.find('a').not(this).addClass('inactive')

    $(e.target.hash).addClass('active')
    $container.find('.tabbed-item').not(e.target.hash).removeClass('active')
