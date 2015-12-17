$ ->
  updateSellerFields = (orgCanSell)->
    if orgCanSell
      $(".organization_name").removeClass('column--full').addClass('column--half')
      $(".seller-fields").removeClass('is-hidden')
    else
      $(".organization_name").removeClass('column--half').addClass('column--full')
      $(".seller-fields").addClass('is-hidden')

  $("#initial_market_id").change (e) ->
    market_id = $(this).val()
    $.get "/admin/markets/#{market_id}/payment_options", (response) =>
      $("#allowed-payment-methods").html(response)

  $("#organization_can_sell").change (e)->
    orgCanSell = $(this).prop("checked")
    updateSellerFields(orgCanSell)
