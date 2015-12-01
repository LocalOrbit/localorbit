getFormData = ($form) ->
  hash = {}
  hash[n['name']] = n['value'] for n in $form.serializeArray()
  hash

validateEIN = () ->
  $field = $("#representative_ein")
  ein = $field.val()

  if ein != undefined && ein != "" && !/^\d{2}-\d{7}$/.test(ein)
    setupErrorsContainer($("#payment-provider-container"))
    $field.wrap('<div class="field_with_errors" />')
    PaymentSourceErrors.displayError('Organization EIN', 'must be 9 digits formatted as XX-XXXXXXX')
    return false

  return true

showCardControls = (accountType) ->
  $("#payment-provider-container").data("provider-object-type", "card")
  $("#bank-account-fields, #underwriting-fields").addClass('is-hidden').prop('disabled', true)
  $("#credit-card-fields").removeClass('is-hidden').prop('disabled', false)
  $("#account_type").val(accountType)
  null

showBankAccountControls = (accountType) ->
  $("#payment-provider-container").data("provider-object-type", accountType)
  $("#bank-account-fields, #underwriting-fields").removeClass('is-hidden').prop('disabled', false)
  $("#credit-card-fields").addClass('is-hidden').prop('disabled', true)
  $("#account_type").val(accountType)
  null

$ ->
  $("#provider_account_type").change (e)->
    accountType = $(this).val()
    if accountType == "card"
      showCardControls(accountType)
    else
      showBankAccountControls(accountType)

  $("#submit-bank-account").click (e) ->
    e.preventDefault()
    if $("#provider_account_type").val()
      $("#payment-provider-container").trigger "submit"
    else
      PaymentSourceErrors.displayErrors($("#payment-provider-container"), [{ param: "account_type", message: "Please select an account type."}])

  $("#payment-provider-container").submit (event) ->
    event.preventDefault()
    return unless validateEIN()

    $(".field_with_errors :input").unwrap()
    $('input[type="submit"]').attr("disabled", "disabled")
    $form = $(event.target)
    data = getFormData($form)
    type = $form.data("provider-object-type")
    realFormId = $form.data("target-form") || "#{type}-uri-form"
    $realForm = $("##{realFormId}")
    $container = $("#payment-provider-container")

    tokenizer = new PaymentSourceTokenizer($realForm, $container, (key) -> "bank_account[#{key}]")
    tokenizer.tokenize(data, type)
      .done (addField) ->
        # success - update custom params before auto-submit
        $("#notes").val if type == "card"
          value = $("#credit-card-notes").val()
        else
          value = $("#bank-account-notes").val()
      .fail ->
        # failure
        $('input[type="submit"]').removeAttr("disabled")


  if accountType = $("#provider_account_type").val()
    if (accountType == 'checking') or (accountType == 'savings')
      showBankAccountControls(accountType)

  $("#provider_account_type").trigger("change");
  