$ ->
  return unless $(".pricing-table").length || $(".product-table").length
  product_fee = false

  formatFieldAsMoney = (field) ->
    field.val(parseFloat(field.val()).toFixed(2))

  $('input.lock-field').click ->
    $(this).parent().parent().find('input.net-price').prop('disabled', true);

  bindCalculator = (el) ->
    salePrice = $(el)
    lock_label = salePrice.parents('tr').first().find('label.lock-label')
    netprice_checkbox = salePrice.parents('tr').first().find('input.lock-field')
    fee = salePrice.parents('tr').first().find('input.fee')
    use_mkt_fee = salePrice.parents('tr').first().find('input.mkt-fee')
    use_product_fee = salePrice.parents('tr').first().find('input.product-fee')
    netPrice = salePrice.parents('tr').first().find('input.net-price')
    selectedMarket = salePrice.parents('tr').first().find('select.price_market_id')

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

      ccRate = netPrice.data('cc-rate')

      if marketId == ""
        marketId = "all"

      if use_product_fee.prop('checked')
        if getFeeValue() > 0
          return 1 - (getFeeValue()/100 + ccRate)
        else
          return 0.00
      else
        if marketToNetPercentMap?
          netPercent = marketToNetPercentMap[marketId]
          return netPercent
        else
          return 0.00

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

    netprice_checkbox.on 'click', ->

      if netprice_checkbox.prop('checked')
        netPrice.prop('disabled', true).css('background','#EFEFEF')
      else
        netPrice.prop('disabled', false).css('background','#FFF')

      updateSalePrice()

    use_mkt_fee.on 'click', ->
      fee.hide()
      lock_label.hide()
      setFeeValue(0)
      updateSalePrice()
      if netprice_checkbox.prop('checked')
        lock_label.click()

      netPrice.prop('disabled', false).css('background','#FFF')
      use_mkt_fee.prop('checked','checked')

    use_product_fee.on 'click', ->
      fee.show()
      lock_label.show()
      use_product_fee.prop('checked','checked')

    salePrice.change ->
      if netprice_checkbox.prop('checked')
        updateFee()
      else
        updateNetPrice()

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

    netPrice.parent().parent().parent().find('input.product-fee:checked').trigger('click')

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
