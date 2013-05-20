<?php


?>
<h1>Invoices</h1>

<?php
core::replace('payables_actions');
core::js("$('#payables_list,#payables_actions').toggle();");
?>