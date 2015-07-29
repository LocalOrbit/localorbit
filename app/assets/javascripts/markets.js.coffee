$ ->
  $('#market_allow_purchase_orders').click ->
    $('#market_require_purchase_orders_span').toggle()

  $('.market-managers .delete button.delete').hover (e) ->
    $(this).closest('tr').toggleClass('destructive')

