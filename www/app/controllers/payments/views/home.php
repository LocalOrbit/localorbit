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
	$tabs[] = 'Record Payments to Vendors';
	$tabs[] = 'Send Invoices and Enter Receipts';
	$tabs[] = 'Review Payment History';
	$payables = true;
	$receivables = true;
}
else if(lo3::is_seller())
{
	$count = core_db::col('select count(payable_id) as mycount from payables where from_org_id='.$core->session['org_id'],'mycount');
	$tabs[] = 'Overview';
	if($count > 0)
	{
		$tabs[] = 'Review Orders &amp; Make Payments';
		$payables = true;
	}
	$receivables = true;
	$tabs[] = 'Review &amp; Deliver Orders';
	$tabs[] = 'Review Payment History';
}
else
{
	$tabs[] = 'Overview';
	$tabs[] = 'Record Payments to Vendors';
	$tabs[] = 'Send Invoices and Enter Receipts';
	$tabs[] = 'Review Payment History';
	$payables = true;
}

// page_header *******************************************************************************
page_header('Financial Management');
echo('<form name="paymentsForm" class="form-horizontal">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
echo('<div class="tab-content">');

core_ui::inline_message("Overview", "This is a snapshot of all money currently owed to your organization and that you owe to other organizations.");




// filters *******************************************************************************
global $hub_filters,$to_filters,$from_filters;

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
	
	
}
else if(lo3::is_seller())
{
	$hub_filters = new core_collection('
		select domain_id,name
		from domains
		where domain_id in (select domain_id from organizations_to_domains where org_id='.$core->session['org_id'].')
		or domain_id in (select sell_on_domain_id from organization_cross_sells where org_id='.$core->session['org_id'].')
	');
	$hub_filters->sort('name');
	
	$count = core_db::col('select count(payable_id) as mycount from payables where from_org_id='.$core->session['org_id'],'mycount');
}





// tab contents ******************************************************************************* = 0;
$tab_count = 0;  //affects ids
$this->overview($tab_count);

if($payables)
{
	$tab_count++;
	$this->review_orders($tab_count);
}
if($receivables)
{
	$tab_count++;
	$this->review_deliver_orders($tab_count);
}
$tab_count++;
$this->payment_history($tab_count);




/*
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
else if(lo3::is_seller())
{

	$hub_filters = new core_collection('
		select domain_id,name
		from domains
		where domain_id in (select domain_id from organizations_to_domains where org_id='.$core->session['org_id'].')
		or domain_id in (select sell_on_domain_id from organization_cross_sells where org_id='.$core->session['org_id'].')
	');
	$hub_filters->sort('name');

	#$tabs = array('Overview', 'Payments Owed', 'Transaction Journal');
}


// remove 'Payments Owed' col if no orders have been placed ever



page_header('Financial Management - Coming Soon!');
echo('<form name="paymentsForm" class="form-horizontal">');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
echo('<div class="tab-content">');
core_ui::inline_message("Overview", "This is a snapshot of all money currently owed to your organization and that you owe to other organizations.");

$tab_count = 1;
$payables_id = 0;

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
	$payables_id = $tab_count;
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


if($core->data['link_payables'] == 'yes')
{
	core::js("$('#paymentstabs-s".$payables_id."').click();");
}


?>


	</div>
	<input type="hidden" name="invoice_list" value="" />
	<input type="hidden" name="payment_from_tab" value="" />
</form>
<?
core::js("$('[rel=\"clickover\"]').clickover({ html : true, onShown : function () { core.changePopoverExpandButton(this, true); }, onHidden : function () { core.changePopoverExpandButton(this, false); } });");
*/
?>