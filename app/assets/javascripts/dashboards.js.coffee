#$ ->
#  sales_data = {
#    labels: ["January", "February", "March", "April", "May", "June", "July"],
#    datasets: [
#      {
#        label: "My First dataset",
#        fillColor: "rgba(220,220,220,0.2)",
#        strokeColor: "rgba(220,220,220,1)",
#        pointColor: "rgba(220,220,220,1)",
#        pointStrokeColor: "#fff",
#        pointHighlightFill: "#fff",
#        pointHighlightStroke: "rgba(220,220,220,1)",
#        data: [65, 59, 80, 81, 56, 55, 40]
#      }
#    ]
#  }
#
#  ctx = document.getElementById("sales-widget").getContext("2d");
#  myLineChart = new Chart(ctx).Line(sales_data);
#
#  #sales_data = labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], series: [[5, 2, 4, 2, 0]]
#  #sales_options =  low: 0, showArea: true
#  #new Chartist.Line('#sales-widget', sales_data, sales_options);
#
#  orders_data = {
#    labels: ["January", "February", "March", "April", "May", "June", "July"],
#    datasets: [
#      {
#        label: "My First dataset",
#        fillColor: "rgba(220,220,220,0.2)",
#        strokeColor: "rgba(220,220,220,1)",
#        pointColor: "rgba(220,220,220,1)",
#        pointStrokeColor: "#fff",
#        pointHighlightFill: "#fff",
#        pointHighlightStroke: "rgba(220,220,220,1)",
#        data: [65, 59, 80, 81, 56, 55, 40]
#      }
#    ]
#  }
#
#  ctx = document.getElementById("orders-widget").getContext("2d");
#  myLineChart = new Chart(ctx).Bar(orders_data);
#
#  #orders_data = labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], series: [[5, 2, 4, 2, 0]]
#  #new Chartist.Bar('#orders-widget', orders_data);
#
#  deliveries_data = {
#    labels: ["January", "February", "March", "April", "May", "June", "July"],
#    datasets: [
#      {
#        label: "My First dataset",
#        fillColor: "rgba(220,220,220,0.2)",
#        strokeColor: "rgba(220,220,220,1)",
#        pointColor: "rgba(220,220,220,1)",
#        pointStrokeColor: "#fff",
#        pointHighlightFill: "#fff",
#        pointHighlightStroke: "rgba(220,220,220,1)",
#        data: [65, 59, 80, 81, 56, 55, 40]
#      }
#    ]
#  }
#
#  ctx = document.getElementById("deliveries-widget").getContext("2d");
#  myLineChart = new Chart(ctx).Bar(deliveries_data);

  #deliveries_data = labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'], series: [[5, 2, 4, 2, 0]]
  #new Chartist.Line('#deliveries-widget', deliveries_data);
