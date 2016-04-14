$ ->
  $("input.check-all").change ->
    $("input[name='item_ids[]']").prop("checked", $(this).prop("checked"))

  $("#mark-all-delivered").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to mark all items delivered?")
      $(".order-item-row .delivery-status > input").val("delivered")
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
