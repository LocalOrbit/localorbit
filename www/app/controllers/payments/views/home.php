<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'payments-home', '');
core_ui::fullWidth();
core::head('Financial Management (beta)','This page is used to manage your payables, invoices, payments');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','payments.js');




// tabs *******************************************************************************
$tabs = array();
$payables = false;
$receivables = false;

# just any random positive nbr. This determines if the money out section in overview is shown.
# this really only needs to be dynamic for sellers, for all other roles just assume there's a positive #.
$money_out_count = 10;
if(lo3::is_admin() || lo3::is_market())
{
	$tabs[] = 'Overview';
	
	if(lo3::is_admin()) {
		$tabs[] = 'Send Invoices and Enter Receipts';
	} else if(lo3::is_fully_managed()) {
		$tabs[] = 'View Invoices';
	} else {
		$tabs[] = 'Send Invoices and Enter Receipts';
	}
	
	if(lo3::is_admin()) {
		$tabs[] = 'Make or Record Payments to Vendors';
	} else if(lo3::is_fully_managed()) {		
		$tabs[] = 'View Payments to Vendors';
	} else {
		$tabs[] = 'Record Payments to Vendors';
	}
	
	
	$tabs[] = 'Review Payment History';
	$payables = true;
	$receivables = true;
}
else if(lo3::is_seller())
{
	$money_out_count = core_db::col('select count(payable_id) as mycount from payables where from_org_id='.$core->session['org_id'],'mycount');
	$tabs[] = 'Overview';
	$tabs[] = 'Review &amp; Deliver Orders';
	$receivables = true;
	if($money_out_count > 0)
	{
		$tabs[] = 'Review Orders &amp; Make Payments';
		$payables = true;
	}
	
	$tabs[] = 'Review Payment History';
}
else
{
	$tabs[] = 'Overview';
	$tabs[] = 'Review Orders &amp; Make Payments';
	$tabs[] = 'Review Payment History';
	$payables = true;
}

// page_header *******************************************************************************
page_header('Financial Management');
echo('<form name="paymentsForm" class="form-horizontal">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
echo('<div class="tab-content">');

core_ui::inline_message("Overview", "This is a snapshot of all money currently owed to your organization and that you owe to other organizations.");



// tab contents ******************************************************************************* = 0;
$tab_count = 0;  //affects ids
$this->overview($tab_count,$money_out_count,count($tabs));
if($receivables)
{
	$tab_count++;
	$this->receivables($tab_count);
}
if($payables)
{
	$tab_count++;
	$this->review_orders($tab_count);
}

$tab_count++;
$this->payment_history($tab_count);

?>