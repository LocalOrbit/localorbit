<?php


?>
<h1>Payment</h1>
<div class="pull-right">
	<button class="btn btn-warning" onclick="$('#payables_list,#payables_actions').toggle();">Cancel</button>
	<button class="btn btn-primary">Enter Payments</button>
</div>
<?php
core::replace('payables_actions');
core::js("$('#payables_list,#payables_actions').toggle();");
?>