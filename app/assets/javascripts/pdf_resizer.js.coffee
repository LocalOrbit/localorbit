$ ->
  fitText = (id, maxHeight, minFont) ->
    element = $(id)
    height = $(element)?[0]?.scrollHeight
    while height > maxHeight
      fontSize = $(element).css("font-size").replace(/px/, "")
      $(element).css "font-size", (fontSize * 0.95) + "px"
      newHeight = $(element)?[0]?.scrollHeight
      height = (if (newHeight is height or fontSize <= minFont) then -1 else newHeight)

  resizeContent = ->
    fitText("#farm-content", 1800, 9)

  resizeHeader = ->
    fitText("#headerText", 56, 24)
    $('#headerText').css('margin-top', $('#productContent').height() * 0.15 + 'px')

  resizeContent()
  resizeHeader()