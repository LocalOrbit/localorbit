$ ->

  $('.input-append.color').colorpicker()
    .on('changeColor', (ev) ->
      update_swatch()
    )
    .on('hide', (ev) ->
      update_swatch()
    )

  update_swatch = ->
      $('#background_swatch').css('background-color', $('#market_background_color').val())

  update_swatch()
