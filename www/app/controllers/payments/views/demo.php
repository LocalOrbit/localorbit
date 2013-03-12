<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'payments-demo', '');

core_ui::fullWidth();

core::head('Financial Management','This page is used to manage your payables, invoices, payments');
lo3::require_permission();
lo3::require_login();

core_ui::load_library('js','payments.js');

$total_orders = 0;
if(!lo3::is_admin() && !lo3::is_market() && lo3::is_seller())
	$total_orders = core_db::col('select count(lo_oid) as mycount from lo_order where ldstat_id<>1 and org_id='.$core->session['org_id'].';','mycount');

$has_pos = true;
if(!lo3::is_admin() && !lo3::is_market())
	$has_pos = ((core_db::col('select count(lo_oid) as mycount from lo_order where payment_method=\'purchaseorder\' and org_id='.$core->session['org_id'].';','mycount') > 0));


$tabs = array();
$tabs[] = 'Overview';
if(lo3::is_admin() || lo3::is_market() || lo3::is_seller() || $has_pos)
	$tabs[] = 'Purchase Orders';
if(lo3::is_admin() || lo3::is_market() || lo3::is_seller())
	$tabs[] = 'Receivables';
if(lo3::is_admin() || lo3::is_market() || $has_pos)
	$tabs[] = 'Payables';
$tabs[] = 'Transaction Journal';
if(lo3::is_admin())
	$tabs[] = 'Systemwide Payables/Receivables';
	
# if we got through all those rules and the user only has overview and transaction journal,
# then remove transaction journal
if(count($tabs) == 2)
{
	array_shift($tabs);
}


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
	#$tabs[] = 'Payables';
	
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
	#$tabs[] = 'Receivables';
}
else
{
	#$tabs = array('Overview', 'Payments Owed', 'Transaction Journal');
}


// remove 'Payments Owed' col if no orders have been placed ever



page_header('Financial Management - Coming Soon!');
echo('<form name="paymentsForm">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
echo('<div class="tab-content">');

$tab_count = 1;

if(in_array('Overview',$tabs))
{
	$this->overview($tab_count,$tabs);
	$tab_count++;
}
if(in_array('Purchase Orders',$tabs))
{
	$this->purchase_orders($tab_count);
	$tab_count++;
}
if(in_array('Receivables',$tabs))
{
	$this->receivables($tab_count);
	$tab_count++;
}
if(in_array('Payables',$tabs))
{
	$this->payables($tab_count);
	$tab_count++;
}
if(in_array('Transaction Journal',$tabs))
{
	$this->transaction_journal($tab_count,count($tabs));
	$tab_count++;
}
if(in_array('Systemwide Payables/Receivables',$tabs))
{
	$this->systemwide_payablesreceivables($tab_count);
	$tab_count++;
}

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


# setup the page header and tab switchers




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

<?
*/
?>