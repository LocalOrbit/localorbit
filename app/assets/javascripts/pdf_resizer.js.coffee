$ ->
  fitText = (element, maxHeight, minFont) ->
    height = $(element)?[0]?.scrollHeight
    while height > maxHeight
      fontSize = $(element).css("font-size").replace(/px/, "")
      $(element).css "font-size", (fontSize * 0.95) + "px"
      newHeight = $(element)?[0]?.scrollHeight
      if (newHeight is height or fontSize <= minFont)
        clipText(element, maxHeight + 2000)
        height = -1
      else
        height = newHeight

  clipText = (element, maxHeight) ->
    height = $(element)[0].scrollHeight
    attempts = 0
    words = $(element).text().split(' ')
    wordCount = words.length
    while(height > maxHeight and attempts < wordCount)
      attempts += 1
      newWords = words[0..(wordCount - (1 + attempts))]
      $(element).text(newWords.join(' '))
      height = $(element)[0].scrollHeight


  resizeContent = ->
    $(".farm-content p").each ->
      el = this
      fitText(el, 1900, 14)

  resizeTTHeader = ->
    $(".headerText").each ->
      el = this
      fitText(el, 56, 24)

  resizeTTFarmName = ->
    $(".tt-farm-name").each ->
      el = this
      fitText(el, 86, 18)

  resizePosterHeader = ->
    $(".farm-name").each ->
      el = this
      fitText(el, 106, 24)

  resizeContent()
  resizeTTHeader()
  resizeTTFarmName()
  resizePosterHeader()
