$("#sold-items").on "click", ".select-all", (e) ->
  checked = $(this).prop('checked')
  $("#sold-items td:first-child input").prop('checked', checked)
