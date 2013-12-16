<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'payments-home', '');
core_ui::fullWidth();
core::head('Financial Management (beta)','This page is used to manage your payables, invoices, payments');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','payments.js');



// tabs *******************************************************************************
$tabs = array();
$tabs[] = 'Overview';

if (lo3::is_buyer()) {
	$tabs[] = 'View Invoices';
}
if (lo3::is_seller() && lo3::is_fully_managed()) {
	$tabs[] = 'Review Orders';
}
if (lo3::is_market()) {	
	if (lo3::is_fully_managed()) {
		$tabs[] = 'View Payments to Vendors';
	} else {
		$tabs[] = 'Send Invoices';
		$tabs[] = 'Record Payments to Vendors';
	}
}

$tabs[] = 'Review Payment History';



//echo ' is_buyer ' . lo3::is_buyer() . ' is_seller ' . lo3::is_seller() . ' is_fully_managed ' .lo3::is_fully_managed() . ' is_market ' .lo3::is_market();



// page_header *******************************************************************************
page_header('Financial Management (beta)');
echo('<form name="paymentsForm" class="form-horizontal">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
echo('<div class="tab-content">');

core_ui::inline_message("Overview", "This is a snapshot of all money currently owed to your organization and that you owe to other organizations.");








// tabs *******************************************************************************
$tab_count = 0; $this->overview($tab_count,$money_out_count,count($tabs));

if (lo3::is_buyer()) {
	#$tabs[] = 'View Invoices';
	$tab_count++; $this->view_invoices($tab_count);
}
if (lo3::is_seller() && lo3::is_fully_managed()) {
	$tabs[] = 'Review Orders';
	$tab_count++; $this->review_orders($tab_count);
}
if (lo3::is_market()) {
	if (lo3::is_fully_managed()) {
		#$tabs[] = 'View Payments to Vendors';
		$tab_count++; $this->view_payments_to_vendors($tab_count);
	} else {
		#$tabs[] = 'Send Invoices';
		$tab_count++; $this->create_invoices($tab_count);
		#$tabs[] = 'Record Payments to Vendors';
		$tab_count++; $this->enter_receipts($tab_count);
	}
}

# $tabs[] = 'Review Payment History';
$tab_count++; $this->payment_history($tab_count);


	



?>