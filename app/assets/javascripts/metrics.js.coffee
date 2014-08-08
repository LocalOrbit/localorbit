$("#interval").change ->
  $("#start_date,#end_date").val("")
  $(this).parents("form").first().submit()

