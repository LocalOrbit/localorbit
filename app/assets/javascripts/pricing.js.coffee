$ ->
  return unless $("#pricing_table").length || $(".product-table").length

  formatFieldAsMoney = (field)->
    field.val(parseFloat(field.val()).toFixed(2))

  bindCalculator = (el)->
    salePrice = $(el)
    netPrice = salePrice.parents('tr').first().find('input.net-price')
    selectedMarket = salePrice.parents('tr').first().find('select.price_market_id')

    getNetPriceValue = ->
      parseFloat(netPrice.val())

    setNetPriceValue = (v) ->
      netPrice.val(v.toFixed(2))

    getSalePriceValue = ->
      parseFloat(salePrice.val())

    setSalePriceValue = (v) ->
      salePrice.val(v.toFixed(2))

    getNetPercent = ->
      marketId = selectedMarket.val()
      marketToNetPercentMap = netPrice.data('net-percents-by-market-id')
      if marketId == ""
        marketId = "all"
      if marketToNetPercentMap?
        netPercent = marketToNetPercentMap[marketId]
        return netPercent
      else
        return 0.00

    updateNetPrice = ->
      x = getSalePriceValue() * getNetPercent()
      setNetPriceValue(x)

    updateSalePrice = ->
      y = getNetPriceValue() / getNetPercent()
      setSalePriceValue(y)

    updateNetPrice()

    salePrice.change ->
      updateNetPrice()

    salePrice.on 'keyup', ->
      $(this).trigger('change')

    salePrice.on 'blur', ->
      formatFieldAsMoney($(this))

    salePrice.trigger('blur')

    netPrice.change ->
      updateSalePrice()

    netPrice.on 'keyup', ->
      $(this).trigger('change')

    netPrice.on 'blur', ->
      formatFieldAsMoney($(this))

    netPrice.trigger('blur')

    selectedMarket.change ->
      updateNetPrice()

  $('input.sale-price').each ->
    bindCalculator(this)

  $('input.edit-price').each ->
    bindCalculator(this)

  EditTable.build "#new_price",
    applyErrorValuesCallback: (field)->
      val = $(field).val()
      if val? && (field.hasClass('sale-price') || field.hasClass('net-price'))
        formatFieldAsMoney($(field))
      if field.hasClass('sale-price')
        $(field).trigger('change')
