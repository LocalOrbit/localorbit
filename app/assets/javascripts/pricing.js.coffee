$ ->
  return unless $("#pricing_table").length || $(".product-table").length

  formatFieldAsMoney = (field)->
    field.val(parseFloat(field.val()).toFixed(2))

  bindCalculator = (el)->
    salePrice = $(el)

    netPrice = salePrice.parents('tr').first().find('input.net-price')

    salePrice.change ->
      val = parseFloat($(this).val())
      netPercent = parseFloat(netPrice.data('net-percent'))
      netPrice.val((val * netPercent).toFixed(2))

    salePrice.on 'keyup', ->
      $(this).trigger('change')

    salePrice.on 'blur', ->
      formatFieldAsMoney($(this))

    salePrice.trigger('blur')

    netPrice.change ->
      val = parseFloat($(this).val())
      netPercent = parseFloat($(this).data('net-percent'))
      salePrice.val((val / netPercent).toFixed(2))

    netPrice.on 'keyup', ->
      $(this).trigger('change')

    netPrice.on 'blur', ->
      formatFieldAsMoney($(this))

    netPrice.trigger('blur')

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
