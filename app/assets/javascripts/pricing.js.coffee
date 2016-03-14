$ ->
  return unless $(".pricing-table").length || $(".product-table").length

  formatFieldAsMoney = (field) ->
    field.val(parseFloat(field.val()).toFixed(2))

  $('input.lock-field').click ->
    $(this).parent().parent().find('input.net-price').prop('disabled', true);

  bindCalculator = (el) ->
    salePrice = $(el)
    fee = salePrice.parents('tr').first().find('input.fee')
    netprice_checkbox = salePrice.parents('tr').first().find('input.lock-field')
    cc_checkbox = salePrice.parents('tr').first().find('input.includecc-field')
    use_mkt_fee = salePrice.parents('tr').first().find('input.mkt-fee')
    use_product_fee = salePrice.parents('tr').first().find('input.product-fee')
    netPrice = salePrice.parents('tr').first().find('input.net-price')
    selectedMarket = salePrice.parents('tr').first().find('select.price_market_id')
    includeCC = cc_checkbox.prop('checked')
    netPriceLocked = netprice_checkbox.prop('checked')

    getNetPriceValue = ->
      parseFloat(netPrice.val())

    setNetPriceValue = (v) ->
      netPrice.val(v.toFixed(2))

    getFeeValue = ->
      parseFloat(fee.val())

    setFeeValue = (v) ->
      fee.val(v.toFixed(2))

    getSalePriceValue = ->
      parseFloat(salePrice.val())

    setSalePriceValue = (v) ->
      salePrice.val(v.toFixed(2))

    getNetPercent = ->
      marketId = selectedMarket.val() || 'all'
      marketToNetPercentMap = netPrice.data('net-percents-by-market-id')

      if includeCC
        ccRate = netPrice.data('cc-rate')
      else
        ccRate = 0

      if marketId == ""
        marketId = "all"

      if getFeeValue() > 0
        return 1-(getFeeValue()/100 + ccRate)

      if marketToNetPercentMap?
        netPercent = marketToNetPercentMap[marketId]
        return netPercent
      else
        return 0.00

#    updateNetPrice = ->
#      if !netPriceLocked
#        salePriceValue = getSalePriceValue()
#        netPercent = getNetPercent()
#        netPriceValue = salePriceValue * netPercent
#      else
#        netPriceValue = getNetPriceValue()
#      setNetPriceValue(netPriceValue)

#    updateSalePrice = ->
#      netPriceValue = getNetPriceValue()
#      netPct = getNetPercent()
#      y = netPriceValue + (netPriceValue * netPct)
#      setSalePriceValue(y)

    updateFee = ->
      netPriceValue = getNetPriceValue()
      salePriceValue = getSalePriceValue()
      feeValue = ((salePriceValue - netPriceValue) / netPriceValue) * 100
      setFeeValue(feeValue)

    updateNetPrice = ->
      salePriceValue = getSalePriceValue()
      netPercent = getNetPercent()
      netPriceValue = salePriceValue * netPercent
      setNetPriceValue(netPriceValue)

    updateSalePrice = ->
      y = getNetPriceValue() / getNetPercent()
      setSalePriceValue(y)

    #updateNetPrice()

    cc_checkbox.on 'click', ->
      includeCC = cc_checkbox.prop('checked')
      updateNetPrice()

    netprice_checkbox.on 'click', ->
      netPriceLocked = netprice_checkbox.prop('checked')
      if netPriceLocked
        $(this).parent().parent().find('input.net-price').prop('disabled', true).css('background','#EFEFEF');
      else
        $(this).parent().parent().find('input.net-price').prop('disabled', false).css('background','#FFF');

      updateSalePrice()

    use_mkt_fee.on 'click', ->
      fee.hide()
      setFeeValue(0)
      use_mkt_fee.prop('checked','checked')

    use_product_fee.on 'click', ->
      fee.show()
      use_product_fee.prop('checked','checked')

    salePrice.change ->
      if !netPriceLocked
        updateNetPrice()
      else
        updateFee()

    salePrice.on 'keyup', ->
      $(this).trigger('change')

    salePrice.on 'blur', ->
      formatFieldAsMoney($(this))

    salePrice.trigger('blur')

    fee.change ->
      updateSalePrice()

    fee.on 'keyup', ->
      $(this).trigger('change')

    fee.trigger('blur')

    netPrice.change ->
      updateSalePrice()

    netPrice.on 'keyup', ->
      $(this).trigger('change')

    netPrice.on 'blur', ->
      formatFieldAsMoney($(this))

    netPrice.trigger('blur')

    selectedMarket.change ->
      updateNetPrice()

    if getFeeValue() > 0
      use_product_fee.trigger('click')
    else
      use_mkt_fee.trigger('click')

  $('input.sale-price').each ->
    bindCalculator(this)

  $('input.edit-price').each ->
    bindCalculator(this)

  EditTable.build ".price-form",
    applyErrorValuesCallback: (field) ->
      val = $(field).val()
      if val? && (field.hasClass('sale-price') || field.hasClass('net-price'))
        formatFieldAsMoney($(field))
      if field.hasClass('sale-price')
        $(field).trigger('change')
