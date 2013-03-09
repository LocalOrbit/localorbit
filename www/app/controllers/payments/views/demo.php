<?php
core::ensure_navstate(array('left'=>'left_dashboard'), 'payments-demo', '');

core_ui::fullWidth();

core::head('Financial Management','This page is used to manage your payables, invoices, payments');
lo3::require_permission();
lo3::require_login();

core_ui::load_library('js','payments.js');

#
$tabs = array();
$tabs[] = 'Overview';
$tabs[] = 'Purchase Orders';
$tabs[] = 'Receivables';
$tabs[] = 'Payables';
$tabs[] = 'Transaction Journal';
$tabs[] = 'Systemwide Payables/Receivables';


# prepare the filters
global $hub_filters,$to_filters,$from_filters;
$hub_filters = false; $to_filters = false; $from_filters = false;
if(lo3::is_admin())
{
	$hub_filters = core::model('domains')->collection()->sort('name');
	$to_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct to_org_id from payables)')
		->sort('name');
	$from_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct from_org_id from payables)')
		->sort('name');
}
else if(lo3::is_market())
{
	$tabs[] = 'Payables';
	
	if(count($core->session['domains_by_orgtype_id'][2]) > 1)
	{
		$hub_filters = core::model('domains')
			->collection()
			->filter('domain_id','in',$core->session['domains_by_orgtype_id'][2])
			->sort('name');
	}
	
	$to_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(
			select org_id
			from organizations_to_domains
			where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
		)')
		->sort('name');
	$from_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(
			select org_id
			from organizations_to_domains
			where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
		)')
		->sort('name');
	$tabs[] = 'Receivables';
}
else
{
	
}

page_header('Financial Management - Coming Soon!');
echo('<form name="paymentsForm">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
echo('<div class="tab-content">');

$this->overview(1);
$this->purchase_orders(2);
$this->receivables(3);
$this->payables(4);
$this->transaction_journal(5);
$this->systemwide_payablesreceivables(6);

?>



	</div>
	<input type="hidden" name="invoice_list" value="" />
	<input type="hidden" name="payment_from_tab" value="" />
</form>
<?

/*

# build the list of tabs that we need to render
global $tabs;



$tabs = array('Overview');
if(lo3::is_market() || lo3::is_admin())
{
	
	$tabs[] = 'Invoices Due';
	
}





$tabs[] = 'Payments Owed';
$tabs[] = 'Transaction Journal';

#if(lo3::is_admin() || lo3::is_market() )
#	$tabs[] = 'Advanced Metrics';
	
# setup the page header and tab switchers




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
	#$this->metrics((array_search('Advanced Metrics',$tabs) + 1)); 
}
$this->transaction_journal((array_search('Transaction Journal',$tabs) + 1)); 
?>
	</div>
	<input type="hidden" name="invoice_list" value="" />
	<input type="hidden" name="payment_from_tab" value="" />
</form>

<?
*/
?>