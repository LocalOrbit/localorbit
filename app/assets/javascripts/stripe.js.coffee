
class @PaymentProvider

  @tokenize: (fields, type, $container) ->
    deferred = $.Deferred()

    Stripe.setPublishableKey($container.data("stripe-publishable-key"))

    params =
      number: fields.card_number,
      exp_month: fields.expiration_month,
      exp_year: fields.expiration_year,
      cvc: fields.security_code,

    Stripe[type].createToken params, (status, response) ->
      error = response.error
      if error
        errors = [{
          param: error.param,
          message: error.message
        }]
        deferred.reject(errors)
      else
        result =
          stripe_tok:       response.id,
          account_type:     response.type,
          bank_name:        response[type].brand,
          last_four:        response[type].last4,
          expiration_month: response[type].exp_month,
          expiration_year:  response[type].exp_year
        deferred.resolve(result)

    deferred.promise()
