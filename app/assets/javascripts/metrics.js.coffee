$ ->
  $("#metric_date_interval").change ->
    $(".date-filters").toggle( $(this).val() == "range" )

  $("metric_date_interval").trigger("change")
