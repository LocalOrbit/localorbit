$(document).ready ->

  stripe_v3 = Stripe($('meta[name="stripe-key"]').attr('content'))

  # Create an instance of Elements
  elements = stripe_v3.elements()

  # Custom styling can be passed to options when creating an Element.
  # (Note that this demo uses a wider set of styles than the guide below.)
  style =
    base:
      color: '#444444'
      lineHeight: '24px'
      fontFamily: 'Helvetica Neue'
      fontSmoothing: 'antialiased'
      fontSize: '16px'
      '::placeholder': color: '#aab7c4'
    invalid:
      color: '#fa755a'
      iconColor: '#fa755a'

  # Create an instance of the card Element
  card = elements.create('card', style: style)

  # Add an instance of the card Element into the `card-element` <div>
  card.mount '#card-element'

  # Handle real-time validation errors from the card Element.
  card.addEventListener 'change', (event) ->
    displayError = document.getElementById('card-errors')
    if event.error
      displayError.textContent = event.error.message
    else
      displayError.textContent = ''
    return

  $.validator.methods.lowercase = (value, element) ->
    @optional(element) or /^[a-z]+$/.test(value)

  $.validator.methods.email = (value, element) ->
    @optional(element) or /(.+)@(.+){2,}\.(.+){2,}/.test(value)

  ###*
  # validateForm
  # Defines the terms of JQuery validation
  #
  ###
  validateForm = (form) ->
    # add 'required' to the class of any field to trigger the cRequired validation class
    $.validator.addMethod 'cRequired', $.validator.methods.required, 'Required field'
    $.validator.addClassRules 'required', cRequired: true

    
    $.validator.addMethod 'cMaxLength', $.validator.methods.maxlength, $.validator.format('May not be longer than {0} characters')
    $.validator.addMethod 'cMaxValue',  $.validator.methods.max, $.validator.format('Must be less that {0}')
    $.validator.addMethod 'cMinValue',  $.validator.methods.min, $.validator.format('Must be greater than {0}')
    $.validator.addClassRules "card_num",   cMaxLength: 16
    $.validator.addClassRules "card_month", cMaxLength: 2, cMinValue: 1, cMaxValue: 12
    $.validator.addClassRules "card_year",  cMaxLength:  4
    $.validator.addClassRules "card_code",  cMaxLength:  3
      
    ret_val = form.validate(
      ignore: "[aria-hidden='true'] :input"
      rules:
        'market[contact_email]':
          email: true
        'market[subdomain]':
          lowercase: true
          synchronousRemote:
            url: '/roll_your_own_market/unique_subdomain'
            type: 'post'
        'details[coupon]': required: false
      messages: 'market[subdomain]':
        synchronousRemote: 'Subdomain already in use'
        lowercase: 'The subdomain may only contain lower case letters')
    ret_val


  change_plan =(modifier) ->
    change_price modifier
    change_interval modifier
    return

  change_price = (modifier) ->
    price_box = $('#details_plan_price')
    new_price = 0
    original_price = price_box.val()
    price_box.prop 'readonly', false
    switch modifier.object
      when 'plan'
        price_box.val modifier.amount / 100
      else
        if modifier.percent_off > 0
          new_price = original_price - (original_price * modifier.percent_off / 100)
        else
          new_price = original_price - (modifier.amount_off)
        price_box.val new_price
        break
    price_box.prop 'readonly', true
    return

  change_interval = (modifier) ->
    cycle = $('#cycle')
    cycle.prop('innerHTML', modifier.interval)
    return

  ###*
  # wizard_nav
  # Coordinates the 'Previous' and 'Continue' button clicks with the corresponding tab interface actions
  ###

  wizard_nav = (button) ->
    validateForm $('#new_market_registration')
    is_valid = $('#new_market_registration').valid()
    if is_valid
      clicked_form_nav = button
      target_tab_nav = $('#market-tab-list').find('a[href="' + clicked_form_nav.attr('target') + '"]')
      target_tab_nav.trigger 'click'
    return

  ###*
  # manage_section_state
  # Manages the tab classes on page load and on input change
  ###

  manage_section_state = (form_section) ->
    # Return immediately if the tab is hidden - no sense in doing extra work
    if form_section.attr('aria-hidden') == "true"
      return

    # Initialize
    form_section_id = form_section.prop('id')
    target_anchor = $('a[href^="#' + form_section_id + '"]')
    target_li = target_anchor.closest('li')

    # Check form validation
    validateForm $('#new_market_registration')
    is_valid = $('#new_market_registration').valid()

    # Set the class accordingly
    if is_valid
      target_li.addClass 'pass'
    else
      target_li.removeClass 'pass'
    return is_valid


  ###* 
  # Page initializers
  #
  ###

  $('#tabs').tabs beforeActivate: (event, ui) ->
    is_valid = manage_section_state ui.oldPanel
    if is_valid != true
      event.preventDefault()
    return is_valid
  $('.wizard_nav').show()
  $('div[id^="form-"]').each ->
    manage_section_state $(this)
    return
  $('button.wizard_nav').click (e) ->
    e.preventDefault()
    ancestor_div = $(this).closest('div[id^="form-"]')
    manage_section_state ancestor_div
    wizard_nav $(this)
    return
  $('#details_plan').change ->
    plan_id = undefined
    retrieved_plan = undefined
    target = undefined
    $('#progress-bar').removeClass 'is-hidden'
    plan_id = $(this).val()
    target = '/roll_your_own_market/get_stripe_plans'
    retrieved_plan = $.post(target, 'plan': plan_id)
    retrieved_plan.success (response) ->
      change_plan response
      $('#apply_discount').prop 'disabled', false
      $('#details_coupon').prop 'readonly', false
      $('#progress-bar').addClass 'is-hidden'
      return
    retrieved_plan.fail (response) ->
      $('#progress-bar').addClass 'is-hidden'
      alert 'There was an error processing the selection'
      return
    return
  $('#apply_discount').click (e) ->
    button = undefined
    coupon = undefined
    discount_box = undefined
    retrieved_coupon = undefined
    target = undefined
    e.preventDefault()
    button = $(this)
    button.prop 'disabled', true
    discount_box = $('#details_coupon')
    coupon = discount_box.val()
    if coupon != ''
      $('#progress-bar').removeClass 'is-hidden'
      target = '/roll_your_own_market/get_stripe_coupon'
      retrieved_coupon = $.post(target, 'coupon': coupon)
      retrieved_coupon.success (response) ->
        change_plan response
        discount_box.prop 'readonly', true
        $('#progress-bar').addClass 'is-hidden'
        return
      retrieved_coupon.fail (response) ->
        discount_box.prop 'readonly', false
        discount_box.val ''
        alert response.responseText
        button.prop 'disabled', false
        $('#progress-bar').addClass 'is-hidden'
        return
    else
      alert 'Please enter a discount code'
      button.prop 'disabled', false
    return
  #return

  new_market =
    setupForm: ->
      $('#new_market_registration').submit ->
        $('input[type=submit]').attr('disabled', true)
        validateForm($('#new_market_registration'))
        validation_boolean = $('#new_market_registration').valid()
        if validation_boolean
          if $('#card-element').length
            stripe_v3.createToken(card).then (result) ->
              if result.error
                # Inform the user if there was an error
                errorElement = document.getElementById('card-errors')
                errorElement.textContent = result.error.message
                console.log result.error.message
                $("#place-order-button").prop("disabled", false)
              else
                # Send the token to your server
                #alert JSON.stringify(result.token)
                #console.log JSON.stringify(result.token)
                # Insert the token ID into the form so it gets submitted to the server
                $('#market_stripe_tok').val(result.token.id)
                $('#new_market_registration')[0].submit()
              return
            false
          else
            true
        else
          $('input[type=submit]').attr('disabled', false)
          false

  ###
    processCard: ->
      card =
        number: $('#card_number').val()
        cvc: $('#security_code').val()
        expMonth: $('#expiration_month').val()
        expYear: $('#expiration_year').val()
      Stripe.createToken(card, new_market.handleStripeResponse)

    handleStripeResponse: (status, response) ->
      if status == 200
        $('#market_stripe_tok').val(response.id)
        $('#new_market_registration')[0].submit()
      else
        alert('Status: ' + status + '\nError message: ' + response.error.message)
        $('input[type=submit]').attr('disabled', false)
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))###

  new_market.setupForm()
