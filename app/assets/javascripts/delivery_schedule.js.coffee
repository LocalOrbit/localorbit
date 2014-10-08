$ ->
  sellerFulfillment = -> $("#delivery_schedule_seller_fulfillment_location_id")
  buyerDay          = -> $("#delivery_schedule_buyer_day")
  sellerDay         = -> $("#delivery_schedule_day")

  enableField = (f) ->
    $(f).
      prop('readonly',false).
      prop('disabled', false)

  disableField = (f) ->
    $(f).
      prop('readonly',true).
      prop('disabled', true)

  #
  # Currently selected "Fulfillment method" determines visibility of Buyer pickup fields:
  #

  disableBuyerPickupFields = ->
    $("#buyer_order_receipt").addClass('is-hidden')
    $("#market_pickup_option").addClass('is-hidden')
    disableField("#buyer_order_receipt")

  enableBuyerPickupFields = ->
    $("#buyer_order_receipt").removeClass('is-hidden')
    $("#market_pickup_option").removeClass('is-hidden')
    enableField("#buyer_order_receipt")

  isDirectToCustomer = ->
    sellerFulfillment().val() == "0"

  # Show/hide buyer fields based on fulfillment tyoe:
  sellerFulfillment().change ->
    if isDirectToCustomer()
      disableBuyerPickupFields()
    else
      enableBuyerPickupFields()
  
  #
  # Synchronize "Day" and "Seller delivery day"
  #
  
  # Utils for selecting options by value:
  optionOf = (obj, optionValue) ->
    $(obj).find("option:eq(#{optionValue})")

  selectOptionByValue = (obj, optionValue) ->
    optionOf(obj,optionValue).prop('selected',true)

  # In-page state: this is a piece of "tape" connecting the 
  # "Day" field to the "Seller delivery day".
  # Initialized below, at page-load time.
  # Once Seller delivery day has been manipulated by a user,
  # "break the tape" and cease on-page sync of the two pulldowns.
  syncSellerDay = false
 
  # Keep "Seller delivery day" synced to "Day" 
  buyerDay().change ->
    if syncSellerDay
      selectOptionByValue(sellerDay(), buyerDay().val())

  # "break the tape" if user picks a Seller day different 
  # than the Buyer "Day"
  sellerDay().change ->
    if sellerDay().val() != buyerDay().val()
      syncSellerDay = false

  # Init: decide if we've arrived at a Delivery Schedule
  # where we should (or shouldn't) sync Day to Seller Delivery Day:
  if buyerDay().val() == sellerDay().val()
    syncSellerDay = true
