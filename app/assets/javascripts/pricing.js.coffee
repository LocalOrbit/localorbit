$ ->
  return unless $("#pricing_table").length

  $('#price_sale_price').change ->
    net_price = $('#price_net_price')
    val = parseFloat($(this).val())
    net_percent = parseFloat(net_price.data('net-percent'))
    net_price.val((val * net_percent).toFixed(2))

  $('#price_sale_price').on 'keyup', ->
    $(this).trigger('change')

  $('#price_net_price').change ->
    sale_price = $('#price_sale_price')
    val = parseFloat($(this).val())
    net_percent = parseFloat($(this).data('net-percent'))
    sale_price.val((val / net_percent).toFixed(2))

  $('#price_net_price').on 'keyup', ->
    $(this).trigger('change')

  EditTable.build
    selector: "#new_price"
    modelPrefix: "price"
