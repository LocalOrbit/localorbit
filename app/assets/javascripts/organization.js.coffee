$ ->
  $("#initial_market_id").change (e) ->
    market_id = $(this).val()
    $.get "/admin/markets/#{market_id}/payment_options", (response) =>
      $("#allowed-payment-methods").html(response)
