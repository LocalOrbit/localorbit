<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'payments-demo', '');

core_ui::fullWidth();

core::head('Financial Management','This page is used to manage your payables, invoices, payments');
lo3::require_permission();
lo3::require_login();

core_ui::load_library('js','payments.js');

# build the list of tabs that we need to render
global $tabs;

if(lo3::is_admin())
{
	$tabs = array('Overview', 'Invoices Due', 'Payables', 'Receivables', 'Payments Owed', 'Transaction Journal'); // 'Advanced Metrics'
}
else if(lo3::is_market())
{
	$tabs = array('Overview', 'Invoices Due', 'Payables', 'Receivables', 'Payments Owed', 'Transaction Journal'); // 'Advanced Metrics'
}
else
{
	$tabs = array('Overview', 'Payments Owed', 'Transaction Journal');
}

	
# setup the page header and tab switchers

page_header('Financial Management - Coming Soon!');
echo('<form name="paymentsForm" class="form-horizontal">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
echo('<div class="tab-content">');


# based on our rules, render the tabs one by one
$this->overview((array_search('Overview', $tabs) + 1)); 
$this->payables((array_search('Payables', $tabs) + 1)); 
$this->payments((array_search('Payments Owed', $tabs) + 1)); 
if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] == 1)
{
	$this->receivables((array_search('Receivables', $tabs) + 1)); 
	$this->invoices((array_search('Invoices Due', $tabs) + 1)); 
}
if(lo3::is_admin() || lo3::is_market() )
{
	#$this->metrics((array_search('Advanced Metrics',$tabs) + 1)); 
}
$this->transaction_journal((array_search('Transaction Journal',$tabs) + 1)); 
?>
	</div>
	<input type="hidden" name="invoice_list" value="" />
	<input type="hidden" name="payment_from_tab" value="" />
</form>