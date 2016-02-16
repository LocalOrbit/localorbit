(->
  new_market = undefined
  $ ->
    strip_key_flag = $('meta[name="stripe-key"]').attr('content')
    if strip_key_flag?
      Stripe.setPublishableKey(strip_key_flag)
      new_market.setupForm()

  new_market =
    setupForm: ->
      $('#new_market_registration').submit ->
        $('input[type=submit]').attr 'disabled', true
        if $('#card_number').length
          new_market.processCard()
          false
        else
          true
    processCard: ->
      card = undefined
      card =
        number: $('#card_number').val()
        cvc: $('#security_code').val()
        expMonth: $('#expiration_month').val()
        expYear: $('#expiration_year').val()
      Stripe.createToken card, new_market.handleStripeResponse
    handleStripeResponse: (status, response) ->
      if status == 200
        $('#market_stripe_card_token').val response.id
        $('#new_market_registration')[0].submit()
      else
        alert 'Status: ' + status + '\nError message: ' + response.error.message
        $('input[type=submit]').attr 'disabled', false

  $(document).ready ->

    change_price = (modifier) ->
      # Initialize
      price_box = $('#details_price')
      new_price = 0
      original_price = price_box.val()
      # Enable the price box...
      price_box.prop 'readonly', false
      # ...and process the supplied object:
      switch modifier.object
        # Plans represent a wholesale replacement
        when 'plan'
          price_box.val modifier.amount / 100
        # Coupons require some mathing
        else
          # Two cases: percent off...
          if modifier.percent_off > 0
            new_price = original_price - (original_price * modifier.percent_off / 100)
          else
            # ...and amount off
            new_price = original_price - (modifier.amount_off)
          price_box.val new_price
          break
      # Re-disable the price box.
      price_box.prop 'readonly', true
      return

    ###*
    # wizard_nav
    # Coordinates the 'Previous' and 'Continue' button clicks with the corresponding tab interface actions
    ###
    wizard_nav = (button) ->
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
        # KXM Everything from here to the end of the method should be abstracted to a validation class.
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

    # Make tabs-IDed ul be, you know, TABS...
    $('#tabs').tabs()

    # The presence of JavaScript means that the form is tabbed.  Show the form navigation
    $('.wizard_nav').show()

    # Trigger section management on load
    $('div[id^="form-"]').each ->
      manage_section_state $(this)
      return

    # Trigger section management whenever input changes, too
    $('input').change ->
      ancestor_div = $(this).closest('div[id^="form-"]')
      manage_section_state ancestor_div
      return

    # Bind a given form nav click to the corresponding tab nav click
    $('button.wizard_nav').click (e) ->
      e.preventDefault()
      wizard_nav $(this)
      return

    # Bind the plan dropdown to an AJAX call to Stripe for plan data
    $('#details_plan').change ->
      # Initialize
      plan_id = $(this).val()
      target = '/roll_your_own_market/get_stripe_plans'
      retrieved_plan = $.post(target, 'plan': plan_id)
      retrieved_plan.success (response) ->
        change_price response
        $('#apply_discount').prop 'disabled', false
        $('#details_coupon').prop 'readonly', false
        return
      retrieved_plan.fail (response) ->
        alert 'There was an error processing the selection'
        return
      return
      
    # Process a discount
    $('#apply_discount').click (e) ->
      # Prevent the form submission.
      e.preventDefault()
      # Disable the button
      $(this).prop 'disabled', true
      # get the submitted discount code
      discount_box = $('#details_coupon')
      coupon = discount_box.val()
      # If the submitted code isn't empty then...
      if coupon != ''
        # show the progress bar...
        $('#progress-bar').removeClass 'is-hidden'
        # ...and look for the code.
        target = '/roll_your_own_market/get_stripe_coupon'
        retrieved_coupon = $.post(target, 'coupon': coupon)
        # If found, then...
        retrieved_coupon.success (response) ->
          # ...calculate the discount and update the price...
          change_price response
          # ...disable further interaction with the discount box... 
          discount_box.prop 'readonly', true
          # ...and hide the progress bar.
          $('#progress-bar').addClass 'is-hidden'
          return
        # if NOT found, then...
        retrieved_coupon.fail (response) ->
          # ...clear the box...
          discount_box.prop 'readonly', false
          discount_box.val ''
          # ...inform the user...
          alert response.responseText
          # ...re-enable the button...
          $(this).prop 'disabled', false
          # ...and hide the progress bar.
          $('#progress-bar').addClass 'is-hidden'
          return
        # If it is blank then alert the error
      else
        alert 'Please enter a discount code'
        $(this).prop 'disabled', false
      return

    return
  return
).call this
