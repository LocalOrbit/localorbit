<?php


?>
<h1>New Invoices</h1>


<h1>Re-send Invoices</h1>


<?php
core::replace('payables_actions');
core::js("$('#payables_list,#payables_actions').toggle();");
?>