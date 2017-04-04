$ ->

  $("#signature").jSignature()

  $("input.check-all").change ->
    $("input[name='item_ids[]']").prop("checked", $(this).prop("checked"))

  $('#submit-multi-button').click ->
    selected = $('#order_batch_action option').filter(':selected').val()
    if selected == 'receipt'
      orderForm = $(this).closest("form")
      orderForm.prop("target", "_blank")
      orderForm.submit()

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

  $("#duplicate_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Duplicate Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#export_invoice_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Export Invoice")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#export_bill_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Export Bill")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#generate_receipt_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Generate Receipt")
    orderForm = $(this).closest("form")
    orderForm.prop("target", "_blank")
    orderForm.submit()

  $("#unclose_order").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Unclose Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#uninvoice_order").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Uninvoice Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#save_sig").click (e) ->
    e.preventDefault()
    datapair = $("#signature").jSignature("getData","base30")
    $("input[name='order[signature_data]']").val(datapair[1])
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#clear_sig").click (e) ->
    e.preventDefault()
    datapair = $("#signature").jSignature("clear")

  $(".shrink_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".shrink_options").show()
    $(this).parent().parent().find(".product_ops").hide()

  $(".shrink_cancel_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".product_ops").show()
    $(this).parent().parent().find(".shrink_options").hide()

  $(".submit_shrink_button").click (e) ->
    e.preventDefault()
    shrink_qty = $(this).parent().parent().find(".shrink_qty").val()
    shrink_cost = $(this).parent().parent().find(".shrink_cost").val()
    transaction_id = $(this).parent().parent().find(".transaction_id").val()
    if shrink_qty > 0 && shrink_cost > 0
      $(this).prop("disabled", "disabled")
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=shrink_qty]").val(shrink_qty)
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=shrink_cost]").val(shrink_cost)
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=transaction_id]").val(transaction_id)
      $(this).parent().parent().parent().parent().parent().parent().parent().find("input[name=commit][type=hidden]").val("Shrink")
      $(this).closest("form").submit()


  $(".submit_undo_shrink_button").click (e) ->
    e.preventDefault()
    $(this).prop("disabled","disabled")
    transaction_id = $(this).parent().parent().data("transaction-id")
    $(this).parent().parent().parent().parent().parent().parent().find("input[name=transaction_id]").val(transaction_id)
    $(this).parent().parent().parent().parent().parent().parent().parent().find("input[name=commit][type=hidden]").val("Undo Shrink")
    $(this).closest("form").submit()

  $(".holdover_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".holdover_options").show()
    $(this).parent().parent().find(".product_ops").hide()

  $(".holdover_cancel_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".product_ops").show()
    $(this).parent().parent().find(".holdover_options").hide()

  $(".repack_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".repack_options").show()
    $(this).parent().parent().find(".product_ops").hide()

  $(".repack_cancel_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".product_ops").show()
    $(this).parent().parent().find(".repack_options").hide()

  $(".submit_holdover_button").click (e) ->
    e.preventDefault()
    holdover_qty = $(this).parent().parent().find(".holdover_qty").val()
    holdover_po = $(this).parent().parent().find(".holdover_po").val()
    holdover_delivery_date = $(this).parent().parent().find(".holdover_delivery_date").val()
    transaction_id = $(this).parent().parent().find(".transaction_id").val()
    if holdover_qty > 0 && ((holdover_po == "New" && holdover_delivery_date) || (holdover_po > 0))
      $(this).prop("disabled","disabled")
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=holdover_qty]").val(holdover_qty)
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=holdover_po]").val(holdover_po)
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=holdover_delivery_date]").val(holdover_delivery_date)
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=transaction_id]").val(transaction_id)
      $(this).parent().parent().parent().parent().parent().parent().parent().find("input[name=commit][type=hidden]").val("Holdover")
      $(this).closest("form").submit()

  $(".submit_undo_holdover_button").click (e) ->
    e.preventDefault()
    $(this).prop("disabled","disabled")
    transaction_id = $(this).parent().parent().data("transaction-id")
    $(this).parent().parent().parent().parent().parent().parent().find("input[name=transaction_id]").val(transaction_id)
    $(this).parent().parent().parent().parent().parent().parent().parent().find("input[name=commit][type=hidden]").val("Undo Holdover")
    $(this).closest("form").submit()

  $(".submit_repack_button").click (e) ->
    e.preventDefault()
    repack_qty = $(this).parent().parent().find(".repack_qty").val()
    repack_product_id = $(this).parent().parent().find(".repack_product_id").val()
    transaction_id = $(this).parent().parent().find(".transaction_id").val()
    if repack_qty > 0 && repack_product_id
      $(this).prop("disabled","disabled")
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=repack_qty]").val(repack_qty)
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=repack_product_id]").val(repack_product_id)
      $(this).parent().parent().parent().parent().parent().parent().find("input[name=transaction_id]").val(transaction_id)
      $(this).parent().parent().parent().parent().parent().parent().parent().find("input[name=commit][type=hidden]").val("Repack")
      $(this).closest("form").submit()

  $(".submit_undo_repack_button").click (e) ->
    e.preventDefault()
    $(this).prop("disabled","disabled")
    transaction_id = $(this).parent().parent().data("transaction-id")
    $(this).parent().parent().parent().parent().parent().parent().find("input[name=transaction_id]").val(transaction_id)
    $(this).parent().parent().parent().parent().parent().parent().parent().find("input[name=commit][type=hidden]").val("Undo Repack")
    $(this).closest("form").submit()