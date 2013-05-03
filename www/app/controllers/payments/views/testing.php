<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'payments-home', '');

core_ui::fullWidth();

core::head('Financial Management','This page is used to manage your payables, invoices, payments');
lo3::require_permission();
lo3::require_login();
page_header('Financial Management');
echo('<form name="paymentsForm" class="form-horizontal">');
echo(core_ui::tab_switchers('paymentstabs',array('Overview','Record Payments to Sellers','Send Invoices &amp; Enter Receipts','Review Transactions')));


?>

	</div>
	<input type="hidden" name="invoice_list" value="" />
	<input type="hidden" name="payment_from_tab" value="" />
</form>