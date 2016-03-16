$(document).ready ->

  $.validator.methods.lowercase = (value, element) ->
    @optional(element) or /^[a-z]+$/.test(value)

  $.validator.methods.email = (value, element) ->
    @optional(element) or /[a-z]+@[a-z]+\.[a-z][a-z]+/.test(value)

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


  ###*
  # change_price
  # Coordinates update to price field, which is submitted for creation of the payment record
  #
  ###

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

  ###*
  # wizard_nav
  # Coordinates the 'Previous' and 'Continue' button clicks with the corresponding tab interface actions
  ###

  wizard_nav = (button) ->
    validateForm $('#new_market_registration')
    validation_boolean = $('#new_market_registration').valid()
    if validation_boolean
      clicked_form_nav = button
      target_tab_nav = $('#market-tab-list').find('a[href="' + clicked_form_nav.attr('target') + '"]')
      target_tab_nav.trigger 'click'
    return

  ###*
  # manage_section_state
  # Manages the tab classes on page load and on input change
  ###

  manage_section_state = (form_section) ->
    pass = true
    form_section_id = form_section.prop('id')
    target_anchor = $('a[href^="#' + form_section_id + '"]')
    target_li = target_anchor.closest('li')
    form_section.find('input').each (index) ->
      if $(this).val() == '' or $(this).val() == null
        pass = false
      if $(this).prop('type') == 'checkbox' and !$(this).is(':checked')
        pass = false
      return
    if pass == true
      target_li.addClass 'pass'
    else
      target_li.removeClass 'pass'
    return

  ###* 
  # Page initializers
  #
  ###

  $('#tabs').tabs()
  $('.wizard_nav').show()
  $('div[id^="form-"]').each ->
    manage_section_state $(this)
    return
  $('input').change ->
    ancestor_div = undefined
    ancestor_div = $(this).closest('div[id^="form-"]')
    manage_section_state ancestor_div
    return
  $('button.wizard_nav').click (e) ->
    e.preventDefault()
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
      change_price response
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
        change_price response
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
          if $('#card_number').length
            new_market.processCard()
            false
          else
            true
        else
          $('input[type=submit]').attr('disabled', false)
          false
    
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

  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  new_market.setupForm()
