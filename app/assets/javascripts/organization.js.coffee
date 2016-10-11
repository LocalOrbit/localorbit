$ ->
  updateSellerFields = (orgCanSell)->
    if orgCanSell
      $(".organization_name").removeClass('column--full').addClass('column--half')
      $(".seller-fields").removeClass('is-hidden')
      $(".buyer-fields").addClass('is-hidden')
    else
      $(".organization_name").removeClass('column--half').addClass('column--full')
      $(".seller-fields").addClass('is-hidden')
      $(".buyer-fields").removeClass('is-hidden')

  orgCanSell = $("input[name='can_sell']").val() == "true" || $("#organization_can_sell").prop("checked")
  updateSellerFields(orgCanSell)

  $("#initial_market_id").change (e) ->
    market_id = $(this).val()
    $.get "/admin/markets/#{market_id}/payment_options", (response) =>
      $("#allowed-payment-methods").html(response)

  $("#organization_can_sell").change (e)->
    orgCanSell = $(this).prop("checked")
    updateSellerFields(orgCanSell)

  updateBuyerFields = (orgCanBuy)->
    if orgCanBuy
      $(".buyer-fields").removeClass('is-hidden')
    else
      $(".buyer-fields").addClass('is-hidden')

  $("#organization_can_buy").change (e)->
    orgCanBuy = $(this).prop("checked")
    updateBuyerFields(orgCanBuy)
  