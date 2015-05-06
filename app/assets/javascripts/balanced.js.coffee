
$.getScript "https://js.balancedpayments.com/v1/balanced.js"

class @PaymentProvider

  @tokenize: (fields, type, $container) ->
    deferred = $.Deferred()

    balanced.init($container.data("balanced-marketplace-uri"))

    params =
      name: fields.name
    if type == 'card'
      params.card_number = fields.card_number
      params.expiration_month = fields.expiration_month
      params.expiration_year = fields.expiration_year
      params.security_code = fields.security_code
    else
      params.routing_number = fields.routing_number
      params.account_number = fields.account_number

    balanced[type].create params, (response) ->

      if response.status == 201
        data = response.data
        result =
          name:         data.name,
          balanced_uri: data.uri,
          last_four:    data.last_four
        if type == 'card'
          result.expiration_month = data.expiration_month
          result.expiration_year =  data.expiration_year
          result.account_type =     data.card_type
          result.bank_name =        data.brand
        else
          result.account_type = data.type
          result.bank_name =    data.bank_name

        deferred.resolve(result)

      else
        messages = if response.error.extras? then response.error.extras else response.error
        errors = []
        for param, message of messages
          errors.push
            param: param,
            message: message

        deferred.reject(errors)

    deferred.promise()
