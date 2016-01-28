(->
  new_market = undefined
  $ ->
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
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
        # # KXM This could (should) be a method call for validation of some kind.  For now it confirms that *something* has been entered
        if $(this).val() == '' or $(this).val() == null
          pass = false
        if $(this).prop('type') == 'checkbox' and !$(this).is(':checked')
          pass = false
        return
      # # KXM Confirm what constitutes a test here and abstract to a validation class
      if pass == true
        target_li.addClass 'pass'
      else
        target_li.removeClass 'pass'
      return

    $ ->
      # Make tabs IDed ul be, you know, TABS...
      $('#tabs').tabs()
      return

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

    #  KXM Placeholder method for button that will likely be removed...
    $('#add_market').click (e) ->
      e.preventDefault()
      alert 'This button will:\nAdd an entry to a table of pending markets, creating the table if necessary\nSpawn another market data entry form'
      return
      
    #  KXM Placeholder method for button that don't yet work...
    $('#apply_discount').click (e) ->
      e.preventDefault()
      alert 'This button will:\nApply a discount to the payment total\nPresumably validate the discount?\nPerform some UI manipulation?'
      return
    return
  return
).call this
