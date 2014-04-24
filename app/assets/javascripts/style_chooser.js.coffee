$ ->
  images = document.getElementsByName('market[background_image]')
  features = {
    color_input: false,
    range_input: false
  }

  color_range = $('<div class="color-picker"/>').append($('<span class="spectrum"/>')).append($('<input class="range-picker" type="range" min="0" max="359" step="1"/>'))
  jqui_slider = $('<div class="color-picker"/>').append($('<span class="spectrum"/>')).append($('<div class="slider"/>'))

  hsl_to_hex = (h, s, l) ->
    h = 360-h
    h = h/360
    s = s/100
    l = l/100
    r = l
    g = l
    b = l

    if l <= 0.5 
      v = l * (1 + s)
    else
      v = l + s - l * s
   
    if v > 0
      m = l + l - v
      sv = (v - m) / v
      h = h * 6
      sextant = parseInt(h,10)
      fract = h - sextant
      vsf = v * sv * fract
      mid1 = m + vsf
      mid2 = v - vsf
   
      switch (sextant)
        when 0
          r = v
          g = mid1
          b = m
        when 1
          r = mid2
          g = v
          b = m
        when 2
          r = m
          g = v
          b = mid1
        when 3
          r = m
          g = mid2
          b = v
        when 4
          r = mid1
          g = m
          b = v
        when 5
          r = v
          g = m
          b = mid2

    r = Math.round(r * 255).toString(16)
    g = Math.round(g * 255, 10).toString(16)
    b = Math.round(b * 255, 10).toString(16)
    if r.length == 1
        r = "0" + r

    if g.length == 1
        g = "0" + g

    if b.length == 1
        b = "0" + b
   
    return r+b+g

  hex_to_hsl = (hex) ->
    i = 0
    h = 0.0
    s = 0.0
    min = 255
    max = 0

    if hex.length != 0
      if hex.length ==7
        hex = hex.substr(1,6)

      rgb = [
        parseInt(hex.substr(0,2), 16)/255,
        parseInt(hex.substr(2,2), 16)/255,
        parseInt(hex.substr(4,6), 16)/255
      ]
     
      while i < 3
        if rgb[i] < min
          min = rgb[i]

        if rgb[i] > max
          max = rgb[i];
        i++
     
      delta = max - min
      l = (max + min) / 2
     
      if delta != 0
        if l < 0.5
          s = delta / (max + min)
        else
          s = delta / ( 2.0 - max - min)
     
        delta_r = (((max - rgb[0]) / 6.0) + (max / 2)) / delta
        delta_g = (((max - rgb[1]) / 6.0) + (max / 2)) / delta
        delta_b = (((max - rgb[2]) / 6.0) + (max / 2)) / delta
     
        if rgb[0] == max
          h = delta_b - delta_g
        else if rgb[1] == max
          h = (1.0 / 3.0) + delta_r - delta_b
        else if rgb[2] == max
          h = (2.0 / 3.0) + delta_g - delta_r

        while h < 0.0
          h = h + 1.0
        while h > 1.0
          h = h - 1.0

        h = Math.round(h * 360)
        s = Math.round(s)
        l = parseInt(l * 100, 10)

        return [h, s, l]
      return [0, 0, 0]

  detect_inputs = ->
    field = document.createElement('input')
    field.type = "range"
    if field.type != "text"
      features.range_input = true
    field.type = "color"
    if field.type != "text"
      features.color_input = true


  range_fallback = ->
    $('input.color').each (i, e) ->
      hue = (hex_to_hsl($(e).val().toString()))[0]
      picker = $(color_range).clone()
      $(picker).find('input').attr({
          'value': hue,
          'rel': $(e).attr('id')
        })
      $(picker).insertAfter(e)
      $(e).attr('type', 'hidden')

    $('.range-picker').change (e) ->
        hex = hsl_to_hex(parseInt(e.target.value, 10), 100, 50)
        inp = $('#' + e.target.getAttribute('rel')) 
        $(inp).val("#" + hex)
        $(inp).trigger("change")

  jquery_fallback = ->
    $('input.color').each (i, e) ->
      hue = (hex_to_hsl($(e).val().toString()))[0]
      picker = $(jqui_slider).clone()
      $(picker).insertAfter(e).find('.slider').attr({
          'rel': $(e).attr('id')
        }).slider({
          min: 0, 
          max: 359, 
          step: 1, 
          value: hue,
          change: (event, ui) ->
            hex = hsl_to_hex(parseInt(ui.value, 10), 100, 50)
            inp = $('#' + e.targetparentNode.getAttribute('rel')) 
            $(inp).val("#" + hex)
            $(inp).trigger("change")
      })
      $(e).attr('type', 'hidden')


  update_swatch = ->
      $('#background_swatch').css('background-color', $('#market_background_color').val())

  detect_inputs()

  if features.color_input == false and features.range_input == true
    range_fallback()
  else if features.range_input == false
    jquery_fallback()


  jquery_fallback()
  update_swatch()

  $('#market_background_color').change ->
    update_swatch()

    
