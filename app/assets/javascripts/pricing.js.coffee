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
    markup_pct = salePrice.parents('tr').first().find('div.markup-pct')
    use_mkt_fee = salePrice.parents('tr').first().find('input.mkt-fee')
    use_category_fee = salePrice.parents('tr').first().find('input.category-fee')
    use_product_fee = salePrice.parents('tr').first().find('input.product-fee')
    netPrice = salePrice.parents('tr').first().find('input.net-price')
    selectedMarket = salePrice.parents('tr').first().find('select.price_market_id')
    has_product_fee = fee.hasClass('has-product-fee')

    getNetPriceValue = ->
      parseFloat(netPrice.val())

    setNetPriceValue = (v) ->
      netPrice.val(v.toFixed(2))

    getFeeValue = ->
      parseFloat(fee.val())

    setFeeValue = (v) ->
      fee.val(v.toFixed(2))

    setMarkupValue = (v) ->
      markup_pct.html('Markup %: ' + v.toFixed(2))

    getSalePriceValue = ->
      parseFloat(salePrice.val())

    setSalePriceValue = (v) ->
      salePrice.val(v.toFixed(2))

    getNetPercent = ->
      marketId = selectedMarket.val() || 'all'
      marketToNetPercentMap = netPrice.data('net-percents-by-market-id')

      ccRate = netPrice.data('cc-rate')
      productFee = netPrice.data('product-fee')
      marketToCategoryPercentMap = netPrice.data('category-fee')

      if marketId == ""
        marketId = "all"

      if use_product_fee.prop('checked')
        if getFeeValue() > 0
          return 1 - (getFeeValue()/100 + ccRate)
        else if productFee > 0
          return 1 - (productFee/100 + ccRate)
        else
          return 0.00
      else if use_category_fee.prop('checked')
        if marketToCategoryPercentMap?
          return 1 - (marketToCategoryPercentMap[marketId]/100 + ccRate)
      else
        if marketToNetPercentMap?
          netPercent = marketToNetPercentMap[marketId]
          return netPercent
        else
          return 0.00

    updateMarkupPct= ->
      netPriceValue = getNetPriceValue()
      salePriceValue = getSalePriceValue()
      feeValue = ((salePriceValue - netPriceValue) / netPriceValue) * 100
      setMarkupValue(feeValue)

    updateFee = ->
      netPriceValue = getNetPriceValue()
      salePriceValue = getSalePriceValue()
      feeValue = (1-netPriceValue/salePriceValue)*100
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
      markup_pct.hide()
      setFeeValue(0)
      updateSalePrice()
      if netprice_checkbox.prop('checked')
        lock_label.click()

      netPrice.prop('disabled', false).css('background','#FFF')
      use_mkt_fee.prop('checked','checked')

    use_category_fee.on 'click', ->
      fee.hide()
      lock_label.hide()
      markup_pct.hide()
      setFeeValue(0)
      updateSalePrice()
      if netprice_checkbox.prop('checked')
        lock_label.click()

      netPrice.prop('disabled', false).css('background','#FFF')
      use_category_fee.prop('checked','checked')

    use_product_fee.on 'click', ->
      fee.show()
      lock_label.show()
      markup_pct.show()
      updateMarkupPct()
      use_product_fee.prop('checked','checked')

    salePrice.change ->
      if netprice_checkbox.prop('checked')
        updateFee()
      else
        updateNetPrice()
      updateMarkupPct()

    salePrice.on 'keyup', ->
      $(this).trigger('change')

    salePrice.on 'blur', ->
      formatFieldAsMoney($(this))

    salePrice.trigger('blur')

    fee.change ->
      updateSalePrice()
      updateMarkupPct()

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
      updateMarkupPct()
      use_mkt_fee.prop('disabled', false)

    netPrice.parent().parent().parent().find('input.product-fee:checked').trigger('click')
    netPrice.parent().parent().parent().find('input.category-fee:checked').trigger('click')
    netPrice.parent().parent().parent().find('input.mkt-fee:checked').trigger('click')

    updateMarkupPct()

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
