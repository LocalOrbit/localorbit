

$ ->
  # KXM This is wrong... what is it really?
  Stripe.setPublishableKey('pk_test_FzWkzLlW04mRRs7iJ4GK2Tfi')
  new_market.setupForm()

new_market =
  setupForm: ->
    $('#new_market_registration').submit ->
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        new_market.processCard()
        false
      else
        true
  
  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#security_code').val()
      expMonth: $('#expiration_month').val()
      expYear: $('#expiration_year').val()
    Stripe.createToken(card, new_market.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      $('#market_stripe_card_token').val(response.id)
      $('#new_market_registration')[0].submit()
    else
      # KXM This should populate the error div
      alert("Status: "+ status + "\nError message: " + response.error.message)
      $('input[type=submit]').attr('disabled', false)
