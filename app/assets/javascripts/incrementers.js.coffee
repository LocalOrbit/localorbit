$ ->
  return false
  $('<button type="button" title="Remove an item" class="decrement font-icon">&#xe02f;</button>').insertBefore('input[name=quantity]')
  $('<button type="button" title="Add an item" class="increment font-icon">&#xe02e;</button>').insertAfter('input[name=quantity]')
  $('input[name=quantity]').parents('td.quantity').addClass('js-incrementers').prev('td').addClass('narrow')
  $('button.decrement').on 'click',  (e) ->
    field = $(e.target).parent().find('input')
    if field.val() != "" && parseInt(field.val(), 10) > 0
      field.val(parseInt(field.val(), 10) - 1)
    field.trigger 'cart.inputFinished'
  $('button.increment').on 'click',  (e) ->
    field = $(e.target).parent().find('input')
    if field.val() == ""
      field.val(1)
    else
      field.val(parseInt(field.val(), 10) + 1)
    field.trigger 'cart.inputFinished'
