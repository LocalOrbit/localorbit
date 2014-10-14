# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Debug =
  on: false
  log: (args...) -> console.log(args...) if Debug.on

Controller =
  updateBatchInvoiceStatus: (status) ->
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
  batchInvoiceProgress: -> $(".batch-invoice-progress")
  batchInvoiceProgressText: -> $(".batch-invoice-progress-text")
  batchInvoiceProgressSpinner: -> $(".batch-invoice-progress-spinner")
  batchInvoiceReady:    -> $(".batch-invoice-ready")
  batchInvoiceErrors:   -> $(".batch-invoice-errors")
  batchInvoiceDownload: -> $(".batch-invoice-download")
  batchInvoiceClose:    -> $(".batch-invoice-close")
  batchInvoiceFailed:    -> $(".batch-invoice-failed")
  batchInvoicePartialFail:    -> $(".batch-invoice-partial-fail")
  batchInvoiceSupportNotice: -> $(".batch-invoice-support-notice")

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
    Poller.callback = Controller.updateBatchInvoiceStatus
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
      Test.mkStatus("complete", "1.0", "http://atomicobject.com", ["LO-14-TAHOEFOODHUB-0000022 - Generating invoice PDF - Unexpected exception in MakeInvoicePdfTempFile", "LO-14-TAHOEFOODHUB-0000023 - Generating invoice PDF - Unexpected exception in MakeInvoicePdfTempFile"]) ]

  seq3: ->
    [ Test.mkStatus("not_started", "0.0")
      Test.mkStatus("failed", "0.9", null, ["Orders not valid in InitializeBatchInvoice"]) ]

  sequenceStates: (states,interval) ->
    handle = setInterval ->
      s = states.shift()
      if s?
        console.log "Sending state",s
        Controller.updateBatchInvoiceStatus(s)
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
