getFormData = ($form) ->
  hash = {}
  hash[n['name']] = n['value'] for n in $form.serializeArray()
  hash

tokenize = (type, info) ->
  deferred = $.Deferred()
  Stripe[type].createToken info, (status, response) =>
    if response.error
      deferred.reject(response.error)
    else
      deferred.resolve(response)

  deferred.promise()

displayStripeError = ($form, error)->
  setupErrorsContainer($form)

  key = error.param
  field_name = key.replace(/_/g, " ")
  field_name = field_name.charAt(0).toUpperCase() + field_name.substr(1)
  $form.find("[name^=#{key}]").wrap('<div class="field_with_errors"/>')
  displayError(field_name, error.message)

displayError = (field, error) ->
  $("#payment-provider-errors").append("<li>#{field}: #{error}</li>")

setupErrorsContainer = ($form) ->
  if $("#payment-provider-errors").length
    $("#payment-provider-errors").html("")
  else
    $form.prepend('<ul id="payment-provider-errors" class="form-errors">')

updateInputs = (object, $form) ->
  fields = {
    "card" : {
      "brand" : "bank_account[bank_name]",
      "name" : "bank_account[name]",
      "last4" : "bank_account[last_four]",
      "exp_month" : "bank_account[expiration_month]",
      "exp_year" : "bank_account[expiration_year]",
    },
    "bank_account" : {
      "bank_name" : "bank_account[bank_name]",
      "last4" : "bank_account[last_four]",
    }
  }

  commonFields = {
    "id" : "bank_account[stripe_id]",
    "type" : "bank_account[account_type]"
  }

  for key, field of fields[object["type"]]
    $("<input>").attr(
      type: 'hidden',
      name: field,
      value: object['card'][key]
    ).appendTo($form)

  for key, field of commonFields
    $("<input>").attr(
      type: 'hidden',
      name: field,
      value: object[key]
    ).appendTo($form)

  $("#notes").val if object["type"] == "card"
    value = $("#credit-card-notes").val()
  else
    value = $("#bank-account-notes").val()

validateEIN = () ->
  $field = $("#representative_ein")
  ein = $field.val()

  if ein != undefined && ein != "" && !/^\d{2}-\d{7}$/.test(ein)
    setupErrorsContainer($("#payment-provider-container"))
    $field.wrap('<div class="field_with_errors" />')
    displayError('Organization EIN', 'must be 9 digits formatted as XX-XXXXXXX')
    return false

  return true

$.getScript "https://js.stripe.com/v2/", ->
  $ ->
    $("#provider_account_type").change (e)->
      val = $(this).val()
      if val == "card"
        $("#payment-provider-container").data("provider-object-type", "card")
        $("#bank-account-fields, #underwriting-fields").addClass('is-hidden').prop('disabled', true)
        $("#credit-card-fields").removeClass('is-hidden').prop('disabled', false)
        $("#account_type").val(val)
      else
        $("#payment-provider-container").data("provider-object-type", "bankAccount")
        $("#bank-account-fields, #underwriting-fields").removeClass('is-hidden').prop('disabled', false)
        $("#credit-card-fields").addClass('is-hidden').prop('disabled', true)
        $("#account_type").val(val)


    $("#submit-bank-account").click (e) ->
      e.preventDefault()
      if $("#provider_account_type").val()
        $("#payment-provider-container").trigger "submit"
      else
        displayStripeError($("#payment-provider-container"), { "param": "account_type", "message": "Please select an account type."})


    $("#payment-provider-container").submit (event) ->
      event.preventDefault()
      return unless validateEIN()

      $form = $(event.target)
      Stripe.setPublishableKey($form.data("stripe-publishable-key"))
      type = $form.data("provider-object-type")

      $(".field_with_errors :input").unwrap()
      $('input[type="submit"]').attr("disabled", "disabled")
      tokenize(type, getFormData($form))
        .done (response) ->
          $("##{type}-id").val(response.uri)
          realFormId = $form.data("target-form") || "#{type}-id-form"
          $realForm = $("##{realFormId}")
          updateInputs(response, $realForm)
          $realForm.submit()
        .fail (error) ->
          displayStripeError($form, error)
          $('input[type="submit"]').removeAttr("disabled")

