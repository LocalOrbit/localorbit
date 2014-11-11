$ ->
  fitText = (element, maxHeight, minFont) ->
    height = $(element)?[0]?.scrollHeight
    while height > maxHeight
      fontSize = $(element).css("font-size").replace(/px/, "")
      $(element).css "font-size", (fontSize * 0.95) + "px"
      newHeight = $(element)?[0]?.scrollHeight
      height = (if (newHeight is height or fontSize <= minFont) then -1 else newHeight)

  resizeContent = ->
    $(".farm-content").each ->
      el = this
      fitText(el, 1900, 14)

  resizeTTHeader = ->
    $(".headerText").each ->
      el = this
      fitText(el, 56, 24)

  resizePosterHeader = ->
    $(".farm-name").each ->
      el = this
      fitText(el, 106, 24)

  resizeContent()
  resizeTTHeader()
  resizePosterHeader()