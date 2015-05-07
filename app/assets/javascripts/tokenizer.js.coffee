
class @PaymentSourceErrors

  @displayError: (field, error) ->
    $("#payment-provider-errors").append("<li>#{field}: #{error}</li>")

  @displayGenericError: (message) ->
    $("#payment-provider-errors").append("<li>#{message}</li>")

  @displayErrors: ($form, errors)->
    @setupErrorsContainer($form)

    for error in errors
      if error.param
        key = error.param
        field_name = key.replace(/_/g, " ")
        field_name = field_name.charAt(0).toUpperCase() + field_name.substr(1)
        $form.find("[name^=#{key}]").wrap('<div class="field_with_errors"/>')
        @displayError(field_name, error.message)
      else
        @displayGenericError(error.message)

  @setupErrorsContainer: ($form) ->
    if $("#payment-provider-errors").length
      $("#payment-provider-errors").html("")
    else
      $form.prepend('<ul id="payment-provider-errors" class="form-errors">')


class @PaymentSourceTokenizer

  constructor: (@$form, @$container, @nameForKey) ->

  # tokenize a payment source and submit the token
  # via the given form
  tokenize: (data, type) ->
    deferred = $.Deferred()

    addField = (key, value, type) =>
      name = @nameForKey(key)
      $("<input>").attr(
        type: 'hidden',
        name: name,
        value: value
      ).appendTo(@$form)

    # PaymentProvider is defined by either stripe.js.coffee or balanced.js.coffee
    PaymentProvider.tokenize(data, type, @$container)
      .done (params) =>
        addField key, value for key, value of params
        deferred.resolve(addField)
        @$form.submit()
      .fail (errors) =>
        PaymentSourceErrors.displayErrors(@$container, errors)
        deferred.reject()

    deferred.promise()

