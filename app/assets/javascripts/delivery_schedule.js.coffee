$ ->
  $("#delivery_schedule_seller_fulfillment_location_id").change ->
    if $(this).val() == "0"
      $("#buyer_order_receipt").addClass('is-hidden')
      $("#market_pickup_option").addClass('is-hidden')
      $("#buyer_order_receipt select").attr("readonly", true).attr("disabled", true)
    else
      $("#buyer_order_receipt").removeClass('is-hidden')
      $("#market_pickup_option").removeClass('is-hidden')
      $("#buyer_order_receipt select").attr("readonly", false).attr("disabled", false)
