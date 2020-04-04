$ ->
  $("input.check-all").change ->
    $("input[name='item_ids[]']").prop("checked", $(this).prop("checked"))

  $("#mark-all-delivered").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to mark all items delivered?")
      $(".order-item-row .delivery-status > input").val("delivered")
      amt = $(".order-item-row .quantity-ordered-ro").val()
      if $(".order-item-row .quantity .quantity-delivered").val() == null
        $(".order-item-row .quantity .quantity-delivered").val(amt)
      $(this).closest("form").submit()

  $("#undo-delivery").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to UNDO marking all of these items delivered?")
      $(".order-item-row .delivery-status > input").val("pending")
      $(".order-item-row .delivered-at > input").val('NULL')
      $(".order-item-row .quantity .quantity-delivered").val("")
      $(this).closest("form").submit()

  $(".order-item-row .action-link a").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove this item?")
      $(this).parent().find("input").val("true")
      $(this).closest("form").submit()

  # Change Delivery
  $("#delivery-changer").on "click", "a", (e) ->
    e.preventDefault()
    $("#delivery-changer .fields").toggleClass('is-hidden')
    $("#delivery-changer a").toggleClass('is-hidden')

  $(".delivery-clear").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove the fee?")
      $(this).parent().find("input").val("true")
      $(this).closest("form").submit()


  $(".credit-clear").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove the credit?")
      $(this).parent().find("input").val("true")
      $(this).closest("form").submit()

  $("#merge_button").click (e) ->
    e.preventDefault()
    $("#merge_options").show()
    $(".button-bar").hide()

  $("#merge_cancel_button").click (e) ->
    e.preventDefault()
    $("#merge_options").hide()
    $(".button-bar").show()

  $("#uninvoice_order").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Uninvoice Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")