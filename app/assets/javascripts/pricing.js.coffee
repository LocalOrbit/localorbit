$ ->
  return unless $("#pricing_table").length

  formatFieldAsMoney = (field)->
    field.val(parseFloat(field.val()).toFixed(2))

  bindCalculator = (el)->
    salePrice = $(el)

    netPrice = salePrice.parents('tr').first().find('.net-price')

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

  $('#add-price-toggle').click (e) ->
    e.preventDefault()
    $(this).hide()
    $('#add-price').show()

  $('#add-price .cancel').click (e) ->
    e.preventDefault()
    $('#add-price').hide()
    $('#add-price-toggle').show()

    $('#add-price input').each ->
      field = $(this)
      field.val(field.attr("value"))

    $('#add-price select').each ->
      $(this).val("")

  EditTable.build "#new_price",
    applyErrorValuesCallback: (field)->
      val = $(field).val()
      if val? && (field.hasClass('sale-price') || field.hasClass('net-price'))
        formatFieldAsMoney($(field))
      if field.hasClass('sale-price')
        $(field).trigger('change')
