$ ->
  window.featured_toggle = ->
    toggle_icon = ->
      toggle = $('.featured-product-toggle')
      if toggle.hasClass('icon-minus-circle')
        toggle.removeClass('icon-minus-circle')
        toggle.addClass('icon-plus-circle')
      else
        toggle.addClass('icon-minus-circle')
        toggle.removeClass('icon-plus-circle')

    $('.featured-product-toggle').on 'click', (e) ->
      heading = $('.featured-heading')

      if heading.hasClass('collapsed')
        heading.toggleClass('collapsed')
        toggle_icon()
      else
        $('.products-featured .slide-content').one window.features.transitions, (e) ->
          heading.toggleClass('collapsed')
          toggle_icon()

  window.featured_toggle()
