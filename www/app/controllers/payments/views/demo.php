<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Order Management','This page is used to manage orders');
lo3::require_permission();
lo3::require_login();

core_ui::load_library('js','payments.js');

# build the list of tabs that we need to render
global $tabs;
$tabs = array('Overview');
if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1)
{
	$tabs[] = 'Receivables';
	$tabs[] = 'Invoices Due';
	
}
$tabs[] = 'Payables';
$tabs[] = 'Payments Owed';
$tabs[] = 'Transaction Journal';

#if(lo3::is_admin() || lo3::is_market() )
#	$tabs[] = 'Advanced Metrics';
	
# setup the page header and tab switchers
core_ui::tabset('paymentstabs');
page_header('Payments Portal');
echo('<form name="paymentsForm">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));

# based on our rules, render the tabs one by one
$this->overview((array_search('Overview',$tabs) + 1)); 
$this->payables((array_search('Payables',$tabs) + 1)); 
$this->payments((array_search('Payments Owed',$tabs) + 1)); 
if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1)
{
	$this->receivables((array_search('Receivables',$tabs) + 1)); 
	$this->invoices((array_search('Invoices Due',$tabs) + 1)); 
	
}
if(lo3::is_admin() || lo3::is_market() )
{
	$this->metrics((array_search('Advanced Metrics',$tabs) + 1)); 
}
$this->transaction_journal((array_search('Transaction Journal',$tabs) + 1)); 
?>
	<input type="text" name="invoice_list" value="" />
	<input type="text" name="payment_from_tab" value="" />
</form>