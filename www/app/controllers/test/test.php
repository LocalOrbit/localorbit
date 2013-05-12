

  
  
  
  <link rel="stylesheet" href="http://jqueryui.com/jquery-wp-content/themes/jqueryui.com/style.css" />
  <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  
  <script>
  $(function() {
    $( "#datepicker" ).datepicker({
      changeMonth: true,
      changeYear: true,
      onClose: function() {
			alert("close");
    } 
    });
  });
  </script>
 
<p>Date: <input type="text" id="datepicker" /></p>
	