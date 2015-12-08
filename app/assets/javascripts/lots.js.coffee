$ ->
  $('.adv_inventory').click ->
    $(this).parent().find('.adv_option').toggle()

  $('.adv_inventory:checked').each ->
    $(this).parent().find('.adv_option').toggle()
    $(this).attr('disabled', true)