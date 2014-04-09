$("thead th:first-child").on "click", ".select-all", (e) ->
  checked = $(this).prop('checked')
  $($(this).parents('table').first()).find("tbody td:first-child input").prop('checked', checked)
