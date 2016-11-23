$ ->
  $("#datafile").click (e) ->
    $("#import_button").removeAttr("disabled")

  $("#import_button").click (e) ->
    e.preventDefault
    $(this).attr("disabled","disabled")
    $(this).closest("form").submit()