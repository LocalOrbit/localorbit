$ ->
  $("input.check-all").change ->
    $("input[name='location_ids[]']").prop("checked", $(this).prop("checked"))
