$ ->
  fitText = (element, maxHeight, clipHeight, minFont) ->
    height = $(element)?[0]?.scrollHeight
    while height > maxHeight
      fontSize = $(element).css("font-size").replace(/px/, "")
      $(element).css "font-size", (fontSize * 0.95) + "px"
      newHeight = $(element)?[0]?.scrollHeight
      if (newHeight is height or fontSize <= minFont)
        clipText(element, clipHeight)
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
      fitText(el, 1900, 3900, 14)

  resizeTTContent = ->
    $(".tt-farm-content p").each ->
      el = this
      fitText(el, 1900, 2500, 9)

  resizeTTHeader = ->
    $("h1.productName").each ->
      el = this
      fitText(el, 100, 2100, 18)

  resizeTTFarmName = ->
    $(".tt-farm-name").each ->
      el = this
      fitText(el, 86, 2086, 16)

  resizePosterHeader = ->
    $("h1.headerPosterText").each ->
      el = this
      fitText(el, 235, 2235, 24)

  resizePosterFarmName = ->
    $(".farm-name").each ->
      el = this
      fitText(el, 106, 2106, 24)

  resizeContent()
  resizeTTContent()
  resizeTTHeader()
  resizeTTFarmName()
  resizePosterHeader() # Not needed at present?
  resizePosterFarmName()
