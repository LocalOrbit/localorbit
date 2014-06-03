$ ->

  window.fade_flash = ->
    if $('body').hasClass('transitions')
      $('.flash').addClass('is-fading')
      $('.flash').on window.features.transitions, (e) ->
        $(e.target).remove()

      $('.toggle-slide').on 'click', (e) ->
        e.preventDefault()
        $toggle = $(e.target)
        $(e.target.hash).toggleClass('is-up')
        if $toggle.attr('data-toggle-open') && $toggle.attr('data-toggle-closed')
          if $toggle.text() == $toggle.attr('data-toggle-open')
            $toggle.text($toggle.attr('data-toggle-closed'))
          else
            $toggle.text($toggle.attr('data-toggle-open'))

    else
      $('.toggle-slide').on 'click', (e) ->
        e.preventDefault()
        $(e.target.hash).toggleClass('is-up').slide()

      window.setTimeout ->
          $('.flash').fadeOut(500)
        , 3000

  window.fade_flash()
