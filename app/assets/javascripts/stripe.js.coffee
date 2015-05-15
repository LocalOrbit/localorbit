fieldNameMappings =
  number:    'card_number'
  exp_month: 'expiration_month'
  exp_year:  'expiration_year'
  cvc:       'security_code'

class @PaymentProvider

  @tokenize: (fields, type, $container) ->
    deferred = $.Deferred()

    Stripe.setPublishableKey($container.data("stripe-publishable-key"))
    name = fields.name

    params = {}
    for stripeName, appName of fieldNameMappings
      params[stripeName] = fields[appName]

    Stripe[type].createToken params, (status, response) ->
      error = response.error

      if error
        errors = [{
          param: (fieldNameMappings[error.param] || error.param)
          message: error.message
        }]

        deferred.reject(errors)

      else
        result =
          name:             name
          stripe_tok:       response.id
          account_type:     response.type
          bank_name:        response[type].brand
          last_four:        response[type].last4
          expiration_month: response[type].exp_month
          expiration_year:  response[type].exp_year

        deferred.resolve(result)

    deferred.promise()

