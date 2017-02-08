$ ->
  $('.adv_inventory').click ->
    if confirm('Are you sure you want to enable Advanced Inventory? This cannot be undone.')
      $(this).parent().find('.adv_option').toggle()

  $('.adv_inventory:checked').each ->
    $(this).parent().find('.adv_option').toggle()
    $(this).attr('disabled', true)

  $('.quantity_input').keypress (e) ->
    if e.which == 13
      this.form.submit();
      return false
    #<---- Add this line
    return