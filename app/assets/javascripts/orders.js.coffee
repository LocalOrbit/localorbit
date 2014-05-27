$ ->
  $("input.check-all").change ->
    $("input[name='item_ids[]']").prop("checked", $(this).prop("checked"))

  $("#mark-selected-delivered").click (e) ->
    e.preventDefault()
