$ ->
  $('#registration_terms_of_service').prop('checked', false)
  
  $('#new_registration').on 'submit', ->
    $(this).find('.registration-submit').attr('disabled', true)

  updateSellerFields = (orgCanSell)->
    if orgCanSell
      $(".seller-fields").removeClass('is-hidden')
    else
      $(".seller-fields").addClass('is-hidden')

  $("#registration_seller").change (e)->
    orgCanSell = $(this).prop("checked")
    updateSellerFields(orgCanSell)

  updateBuyerFields = (orgCanBuy)->
    if orgCanBuy
      $(".buyer-fields").removeClass('is-hidden')
    else
      $(".buyer-fields").addClass('is-hidden')

  $("#registration_buyer").change (e)->
    orgCanBuy = $(this).prop("checked")
    updateBuyerFields(orgCanBuy)

  orgCanSell = $('#registration_seller').prop("checked")
  orgCanBuy = $('#registration_buyer').prop("checked")

  updateSellerFields(orgCanSell)
  updateBuyerFields(orgCanBuy)
