getFormData = ($form) ->
  hash = {}
  hash[n['name']] = n['value'] for n in $form.serializeArray()
  hash

tokenize = (type, info) ->
  deferred = $.Deferred()
  balanced[type].create info, (response) =>
    if response.status == 201
      deferred.resolve(response.data)
    else
      deferred.reject(response.error)

  deferred.promise()

updateInputs = (object, $form) ->
  fields = {
    "card" : {
      "brand" : "bank_account[bank_name]",
      "name" : "bank_account[name]",
      "last_four" : "bank_account[last_four]",
      "uri" : "bank_account[balanced_uri]",
      "card_type" : "bank_account[account_type]",
      "expiration_month" : "bank_account[expiration_month]",
      "expiration_year" : "bank_account[expiration_year]",
    },
    "bank_account" : {
      "bank_name" : "bank_account[bank_name]",
      "name" : "bank_account[name]",
      "last_four" : "bank_account[last_four]",
      "uri" : "bank_account[balanced_uri]",
      "type" : "bank_account[account_type]"
    }
  }

  for key, field of fields[object["_type"]]
    $("<input>").attr(
      type: 'hidden',
      name: field,
      value: object[key]
    ).appendTo($form)

  $("#notes").val if object["_type"] == "card"
    value = $("#credit-card-notes").val()
  else
    value = $("#bank-account-notes").val()

displayErrors = ($form, errors)->
  # (re-)set up error container
  if $("#balanced-js-errors").length
    $("#balanced-js-errors").html("")
  else
    $form.prepend('<ul id="balanced-js-errors" class="form-errors">')

  for key of errors
    field_name = key.replace(/_/g, " ")
    field_name = field_name.charAt(0).toUpperCase() + field_name.substr(1)
    $form.find("[name^=#{key}]").wrap('<div class="field_with_errors"/>')
    $("#balanced-js-errors").append("<li>#{field_name}: #{errors[key]}</li>")

$.getScript "https://js.balancedpayments.com/v1/balanced.js", ->
  $ ->
    $("#balanced_account_type").change (e)->
      val = $(this).val()
      if val == "card"
        $("#balanced-payments-uri").data("balanced-object-type", "card")
        $("#bank-account-fields, #underwriting-fields").addClass('is-hidden').prop('disabled', true)
        $("#credit-card-fields").removeClass('is-hidden').prop('disabled', false)
        $("#account_type").val(val)
      else
        $("#balanced-payments-uri").data("balanced-object-type", "bankAccount")
        $("#bank-account-fields, #underwriting-fields").removeClass('is-hidden').prop('disabled', false)
        $("#credit-card-fields").addClass('is-hidden').prop('disabled', true)
        $("#account_type").val(val)


    $("#submit-bank-account").click (e) ->
      e.preventDefault()
      if $("#balanced_account_type").val()
        $("#balanced-payments-uri").trigger "submit"
      else
        displayErrors($("#balanced-payments-uri"), { "account_type" : "Please select an account type."})


    $("#balanced-payments-uri").submit (event) ->
      event.preventDefault()
      $form = $(event.target)
      balanced.init($form.data("balanced-marketplace-uri"))
      type = $form.data("balanced-object-type")

      $(".field_with_errors :input").unwrap()
      $('input[type="submit"]').attr("disabled", "disabled")
      tokenize(type, getFormData($form))
        .done (payment_object) ->
          $("##{type}-uri").val(payment_object.uri)
          realFormId = $form.data("target-form") || "#{type}-uri-form"
          $realForm = $("##{realFormId}")
          updateInputs(payment_object, $realForm)
          $realForm.submit()
        .fail (error) ->
          messages = if error.extras? then error.extras else error
          displayErrors($form, messages)
          $('input[type="submit"]').removeAttr("disabled")
