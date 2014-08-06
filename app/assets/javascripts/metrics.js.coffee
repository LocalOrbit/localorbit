$ ->
  $("#metric_date_interval").change ->
    currentValue = $(this).val()
    $(".date-filters").toggle(currentValue  == "range" )
    if currentValue == "now"
      hadValues = _.every($("#start_date,#end_date"), (input) -> $(input).val().length > 0 )
      $("#start_date,#end_date").val("")
      $("#start_date,#end_date").parents("form").first().submit() if hadValues

  $("#metric_date_interval").trigger("change")
