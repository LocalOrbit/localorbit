$ ->
KnockoutModules.register "consignment_printable_preview_pdf",
  viewModel: (ko,el) ->
    PdfUriPoller.viewModel(ko,el)

  $("#signature").jSignature()

  $("input.check-all").change ->
    $("input[name='item_ids[]']").prop("checked", $(this).prop("checked"))

  $('#submit-multi-button').click ->
    selected = $('#order_batch_action option').filter(':selected').val()
    if selected == 'receipt' || selected == 'pick_list' || selected == 'invoice'
      orderForm = $(this).closest("form")
      orderForm.prop("target", "_blank")
      orderForm.submit()
      orderForm.prop("target", "")

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
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")

  $("#export_invoice_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Export Invoice")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")

  $("#export_bill_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Export Bill")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")

  $("#generate_receipt_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Generate Receipt")
    orderForm = $(this).closest("form")
    orderForm.prop("target", "_blank")
    orderForm.submit()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")
    orderForm.prop("target", "")


  $("#generate_picklist_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Generate Picklist")
    orderForm = $(this).closest("form")
    orderForm.prop("target", "_blank")
    orderForm.submit()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")
    orderForm.prop("target", "")

  $("#generate_invoice_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Generate Invoice")
    orderForm = $(this).closest("form")
    orderForm.prop("target", "_blank")
    orderForm.submit()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")
    orderForm.prop("target", "")

  $("#unclose_order").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Unclose Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")

  $("#uninvoice_order").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Uninvoice Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("")

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
    unallocated = $(this).parent().parent().parent().data("unallocated")
    if shrink_qty > 0 && shrink_cost >= 0 && shrink_qty <= unallocated
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
    holdover_po = $(this).parent().parent().find(".holdover_po :selected").val()
    holdover_po_text = $(this).parent().parent().find(".holdover_po :selected").text()
    holdover_delivery_date = $(this).parent().parent().find(".holdover_delivery_date").val()
    transaction_id = $(this).parent().parent().find(".transaction_id").val()
    unallocated = $(this).parent().parent().parent().data("unallocated")
    if holdover_qty > 0 && ((holdover_po_text == "New" && holdover_delivery_date) || (holdover_po > 0)) && holdover_qty <= unallocated
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
    unallocated = $(this).parent().parent().parent().data("unallocated")
    if repack_qty > 0 && repack_product_id && repack_qty <= unallocated
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

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Debug =
  on: false
  log: (args...) -> console.log(args...) if Debug.on

Controller =
  updateBatchConsignmentPrintableStatus: (status) ->
    switch
      when State.failed(status)
        Debug.log "Handling 'failed' status:", status
        Poller.stop()
        View.showFailed()
        View.showSupportNotice()
        View.setErrors status.errors
        View.showCloseLink()

        View.hideDownloadLink()
        View.hidePartialFail()
        View.hideProgress()

      when State.completeWithErrors(status)
        Debug.log "Handling 'completeWithErrors' status:", status
        View.hideProgress()
        View.showPartialFail()
        View.showSupportNotice()
        View.setErrors status.errors
        View.setDownloadLink status.pdf_uri
        View.showDownloadLink()
        Poller.stop()

      when State.complete(status)
        Debug.log "Handling 'complete' status:", status
        Poller.stop()
        View.hideProgress()
        View.showReady()
        View.redirectTo status.pdf_uri
        View.setDownloadLink status.pdf_uri
        View.showDownloadLink()
        View.hideFailed()
        View.hidePartialFail()
        View.hideSupportNotice()
        View.hideErrors()

      when State.inProgress(status)
        Debug.log "Handling 'inProgress' status:", status
        View.setProgressText "Progress: #{View.formatPercentString(status.generation_progress)}"
        View.showProgress()
        View.hideFailed()
        View.hidePartialFail()
        View.hideSupportNotice()
        View.hideDownloadLink()
        View.hideErrors()

      when State.notStarted(status)
        Debug.log "Handling 'notStarted' status:", status
        View.setProgressText "Progress: 0%"
        View.showProgress()
        View.hideFailed()
        View.hidePartialFail()
        View.hideDownloadLink()
        View.hideSupportNotice()
        View.hideErrors()

State =
  failed: (status) ->
    status.generation_status == "failed"

  completeWithErrors: (status) ->
    State.complete(status) and State.hasErrors(status)

  complete: (status) ->
    status.generation_status == "complete"

  hasErrors: (status) ->
    status.errors and status.errors.length > 0

  inProgress: (status) ->
    status.generation_status == "generating"

  notStarted: (status) ->
    status.generation_status == "not_started"


View =
  batchInvoiceProgress: -> $(".batch-consignment-printable-progress")
  batchInvoiceProgressText: -> $(".batch-consignment-printable-progress-text")
  batchInvoiceProgressSpinner: -> $(".batch-consignment-printable-progress-spinner")
  batchInvoiceReady:    -> $(".batch-consignment-printable-ready")
  batchInvoiceErrors:   -> $(".batch-consignment-printable-errors")
  batchInvoiceDownload: -> $(".batch-consignment-printable-download")
  batchInvoiceClose:    -> $(".batch-consignment-printable-close")
  batchInvoiceFailed:    -> $(".batch-consignment-printable-failed")
  batchInvoicePartialFail:    -> $(".batch-consignment-printable-partial-fail")
  batchInvoiceSupportNotice: -> $(".batch-consignment-printable-support-notice")

  init: ->
    View.batchInvoiceClose().find("a.close-tab").click ->
      window.close()

  setProgressText: (str) -> View.batchInvoiceProgressText().text(str)
  showProgress: -> View.batchInvoiceProgress().show()
  hideProgress: -> View.batchInvoiceProgress().hide()
  showProgressSpinner: -> View.batchInvoiceProgressSpinner().show()
  hideProgressSpinner: -> View.batchInvoiceProgressSpinner().hide()

  showReady: -> View.batchInvoiceReady().show()
  hideReady: -> View.batchInvoiceReady().hide()

  setDownloadLink: (uri) -> View.batchInvoiceDownload().find("a").prop("href", uri)
  showDownloadLink: -> View.batchInvoiceDownload().show()
  hideDownloadLink: -> View.batchInvoiceDownload().hide()

  showCloseLink: -> View.batchInvoiceClose().show()
  hideCloseLink: -> View.batchInvoiceClose().hide()

  showFailed: -> View.batchInvoiceFailed().show()
  hideFailed: -> View.batchInvoiceFailed().hide()

  showPartialFail: -> View.batchInvoicePartialFail().show()
  hidePartialFail: -> View.batchInvoicePartialFail().hide()

  showSupportNotice: -> View.batchInvoiceSupportNotice().show()
  hideSupportNotice: -> View.batchInvoiceSupportNotice().hide()

  setErrors: (errors) ->
    div = View.batchInvoiceErrors()
    list = div.find(".batch-invoice-error-list")
    list.empty()
    if errors.length > 0
      for error in errors
        bullet = $("<li/>").text(error)
        bullet.appendTo(list)
      div.show()
    else
      div.hide()

  hideErrors: ->
    View.batchInvoiceErrors().hide()

  getStatusPollingUri: ->
    View.batchInvoiceProgress().data("status-uri")

  redirectTo: (uri) ->
    window.location = uri

  formatPercentString: (decimalValue) ->
    percent = (decimalValue * 100).toFixed()
    "#{percent}%"


Poller =
  uri: null
  callback: (data) ->
  millis: 1000
  _polling: false
  _handle: null
  start: ->
    if !Poller._polling
      Poller._polling = true
      Poller._handle = setInterval Poller._fetch, Poller.millis
  stop: ->
    Poller._polling = false
    if Poller._handle?
      clearInterval Poller._handle
      Poller._handle = null
  _fetch: ->
    $.getJSON Poller.uri, (args...) ->
      if Poller._polling
        Poller.callback(args...)

initPoller = ->
  uri = View.getStatusPollingUri()
  if uri?
    View.init()
    Poller.uri = uri
    Poller.callback = Controller.updateBatchConsignmentPrintableStatus
    Poller.start()


Test =
  mkStatus: (status,progress=0.0,pdf_uri=null,errors=[]) ->
    { generation_status: status, generation_progress: progress, pdf_uri:pdf_uri, errors:errors }
  seq0: ->
    [ Test.mkStatus("not_started", "0.0")
      Test.mkStatus("generating", "0.25")
      Test.mkStatus("generating", "0.57")
      Test.mkStatus("generating", "0.82")
      Test.mkStatus("generating", "1.0") ]
  seq1: ->
    [ Test.mkStatus("not_started", "0.0")
      Test.mkStatus("generating", "0.25")
      Test.mkStatus("generating", "0.57")
      Test.mkStatus("generating", "0.82")
      Test.mkStatus("generating", "1.0")
      Test.mkStatus("complete", "1.0", "http://atomicobject.com") ]
  seq2: ->
    [ Test.mkStatus("not_started", "0.0")
      Test.mkStatus("generating", "0.50")
      Test.mkStatus("generating", "1.0")
      Test.mkStatus("complete", "1.0", "http://atomicobject.com", ["LO-14-TAHOEFOODHUB-0000022 - Generating invoice PDF - Unexpected exception in The Generator", "LO-14-TAHOEFOODHUB-0000023 - Generating invoice PDF - Unexpected exception in The Generator"]) ]

  seq3: ->
    [ Test.mkStatus("not_started", "0.0")
      Test.mkStatus("failed", "0.9", null, ["Orders not valid in InitializeBatchConsignmentPrintable"]) ]

  sequenceStates: (states,interval) ->
    handle = setInterval ->
      s = states.shift()
      if s?
        console.log "Sending state",s
        Controller.updateBatchConsignmentPrintableStatus(s)
      else
        clearInterval(handle) if handle
        handle = null
        console.log "(interval ended)"
    , interval

  testSeq0: ->
    Test.sequenceStates(Test.seq0(),1000)

  testSeq1: ->
    Test.sequenceStates(Test.seq1(),1000)

  testSeq2: ->
    Test.sequenceStates(Test.seq2(),1000)

  testSeq3: ->
    Test.sequenceStates(Test.seq3(),1000)

window.BI =
  View: View
  Controller: Controller
  State: State
  Test: Test
  Poller: Poller
  initPoller: initPoller

$(initPoller)
