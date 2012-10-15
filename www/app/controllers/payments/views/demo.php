<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Order Management','This page is used to manage orders');
lo3::require_permission();
lo3::require_login();

global $tabs;
$tabs = array('Overview','Payables','Payments');
if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1)
{
	$tabs[] = 'Receivables';
	$tabs[] = 'Invoices';
	$tabs[] = 'Transaction Journal';
}
if(lo3::is_admin() || lo3::is_market() )
	$tabs[] = 'Metrics';
	
core_ui::tabset('paymentstabs');

page_header('Payments Portal');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
$this->overview((array_search('Overview',$tabs) + 1)); 
$this->payables((array_search('Payables',$tabs) + 1)); 
$this->payments((array_search('Payments',$tabs) + 1)); 
if(lo3::is_admin() || lo3::is_market() || $core->session['allow_sell'] ==1)
{
	$this->receivables((array_search('Receivables',$tabs) + 1)); 
	$this->invoices((array_search('Invoices',$tabs) + 1)); 
	$this->transaction_journal((array_search('Transaction Journal',$tabs) + 1)); 
}
if(lo3::is_admin() || lo3::is_market() )
{
	$this->metrics((array_search('Metrics',$tabs) + 1)); 
}
?>