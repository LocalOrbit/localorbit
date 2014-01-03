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
if (lo3::is_seller()) {
	$tabs[] = 'Seller Orders';
}


if (lo3::is_market()) {
	if ($core->config['domain']['buyer_invoicer'] == '' && $core->config['domain']['seller_payer'] == 'hub') {
		$tabs[] = 'Record Payments to Vendors';		
	}
	if ($core->config['domain']['buyer_invoicer'] == '' && $core->config['domain']['seller_payer'] == 'lo') {
		$tabs[] = 'View Payments to Sellers';	
	}
	if ($core->config['domain']['buyer_invoicer'] == 'hub' && $core->config['domain']['seller_payer'] == 'hub') {
		$tabs[] = 'Send Invoices';
		$tabs[] = 'Enter Receipts';
		$tabs[] = 'Record Payments to Vendors';
	}
	if ($core->config['domain']['buyer_invoicer'] == 'lo' && $core->config['domain']['seller_payer'] == 'lo') {
		$tabs[] = 'Send Invoices';
		$tabs[] = 'Enter Receipts';
		$tabs[] = 'View Payments to Sellers';	
	}
}

$tabs[] = 'Review Payment History';



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
if (lo3::is_seller()) {
	#$tabs[] = 'Seller Orders';
	$tab_count++; $this->seller_orders($tab_count);
}
if (lo3::is_market()) {
	if ($core->config['domain']['buyer_invoicer'] == '' && $core->config['domain']['seller_payer'] == 'hub') {
		#$tabs[] = 'Record Payments to Vendors';
		$tab_count++; $this->record_payments($tab_count);
	}
	if ($core->config['domain']['buyer_invoicer'] == '' && $core->config['domain']['seller_payer'] == 'lo') {
		#$tabs[] = 'View Payments to Sellers';
		$tab_count++; $this->view_payments_to_vendors($tab_count);
	}
	if ($core->config['domain']['buyer_invoicer'] == 'hub' && $core->config['domain']['seller_payer'] == 'hub') {
		#$tabs[] = 'Send Invoices';
		$tab_count++; $this->create_invoices($tab_count);
		#$tabs[] = 'Enter Receipts';
		$tab_count++; $this->enter_receipts($tab_count);
		#$tabs[] = 'Record Payments to Vendors';
		#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	}
	if ($core->config['domain']['buyer_invoicer'] == 'lo' && $core->config['domain']['seller_payer'] == 'lo') {
		#$tabs[] = 'Send Invoices';
		$tab_count++; $this->create_invoices($tab_count);
		#$tabs[] = 'Enter Receipts';
		$tab_count++; $this->enter_receipts($tab_count);
		#$tabs[] = 'View Payments to Vendors';
		$tab_count++; $this->view_payments_to_vendors($tab_count);
	}
}

# $tabs[] = 'Review Payment History';
$tab_count++; $this->payment_history($tab_count);


	



?>