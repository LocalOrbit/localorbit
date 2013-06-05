<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'payments-home', '');
core_ui::fullWidth();
core::head('Financial Management','This page is used to manage your payables, invoices, payments');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','payments.js');




// tabs *******************************************************************************
$tabs = array();
$payables = false;
$receivables = false;

if(lo3::is_admin() || lo3::is_market())
{
	$tabs[] = 'Overview';
	$tabs[] = 'Send Invoices and Enter Receipts';
	
	if(lo3::is_admin()) {
		$tabs[] = 'Make or Record Payments to Vendors';
	} else {
		$tabs[] = 'Record Payments to Vendors';
	}	
	
	$tabs[] = 'Review Payment History';
	$payables = true;
	$receivables = true;
}
else if(lo3::is_seller())
{
	$count = core_db::col('select count(payable_id) as mycount from payables where from_org_id='.$core->session['org_id'],'mycount');
	$tabs[] = 'Overview';
	$tabs[] = 'Review &amp; Deliver Orders';
	$receivables = true;
	if($count > 0)
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
$this->overview($tab_count);
if($receivables)
{
	$tab_count++;
	$this->review_deliver_orders($tab_count);
}
if($payables)
{
	$tab_count++;
	$this->review_orders($tab_count);
}

$tab_count++;
$this->payment_history($tab_count);

?>