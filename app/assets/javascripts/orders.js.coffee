$ ->
  $("input.check-all").change ->
    $("input[name='item_ids[]']").prop("checked", $(this).prop("checked"))

  $("#mark-all-delivered").click (e) ->
    e.preventDefault()
    $(".order-item-row .delivery-status > input").val("delivered")
    $(this).closest("form").submit()
