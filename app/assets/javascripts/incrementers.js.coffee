$ ->
  $('<button type="button" class="decrement font-icon">&#xe02f;</button><button type="button" class="increment font-icon">&#xe02e;</button>').insertAfter('input[name=quantity]')
  $('button.decrement').on 'click',  (e) ->
    field = $(e.target).parent().find('input')
    if field.val() != "" && parseInt(field.val(), 10) > 0
      field.val(parseInt(field.val(), 10) - 1)
  $('button.increment').on 'click',  (e) ->
    field = $(e.target).parent().find('input')
    if field.val() == ""
      field.val(1)
    else
      field.val(parseInt(field.val(), 10) + 1)
