$ ->
  $('.market-managers .delete button.delete').hover (e) ->
    $(this).closest('tr').toggleClass('destructive')

