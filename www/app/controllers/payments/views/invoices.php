<?php

global $core;

$invoices = core::model('v_invoices')
	->collection()
	->filter('amount_due', '>', 0);

$hub_from_filters = false;
$hub_to_filters = false;
$org_from_filters = false;
$org_to_filters = false;

if(lo3::is_admin())
{
	$hub_from_filters = core::model('domains')->collection()->sort('name');
	$hub_to_filters = core::model('domains')->collection()->sort('name');
	$org_to_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct to_org_id from v_invoices)')
		->sort('name');
	$org_from_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct from_org_id from v_invoices)')
		->sort('name');
}
else if(lo3::is_market())
{
	$invoices->filter('to_org_id' ,'in',
		'(
			select org_id
			from organizations_to_domains 
			where organizations_to_domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
		)'
	);
	
	$assigned_domain_ids_including_admin = array_merge($core->session['domains_by_orgtype_id'][2], array(1));

	if(count($core->session['domains_by_orgtype_id'][2]) > 1)
	{
		$hub_from_filters = core::model('domains')
			->collection()
			->filter('domain_id','in',$assigned_domain_ids_including_admin)
			->sort('name');
		$hub_to_filters = core::model('domains')
			->collection()
			->filter('domain_id','in',$assigned_domain_ids_including_admin)
			->sort('name');
	}

	$org_to_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct to_org_id from v_invoices)')
		->filter(
				'organizations.org_id' ,
				'in',
				'(
						select org_id
						 from organizations_to_domains
						where domain_id in ('.implode(',',$assigned_domain_ids_including_admin).')
					)'
		)
		->sort('name');
	$org_from_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct from_org_id from v_invoices)')
		->filter(
				'organizations.org_id' ,
				'in',
				'(
						select org_id
						 from organizations_to_domains
						where domain_id in ('.implode(',',$assigned_domain_ids_including_admin).')
					)'
		)
		->sort('name');
}
else
{
	$invoices->filter('to_org_id' ,'=',$core->session['org_id']);
}

$invoices->add_formatter('payable_info');
$invoices->add_formatter('payment_link_formatter');
$invoices->add_formatter('payment_direction_formatter');
$invoices_table = new core_datatable('invoices','payments/invoices',$invoices);
$invoices_table = payments_add_standard_filters($invoices_table, $hub_from_filters, $hub_to_filters, $org_from_filters, $org_to_filters, false, false);
$invoices_table->add(new core_datacolumn('invoice_id','Description',true,'22%','<b>I-{invoice_id}</b><br />{description_html}','{description}','{description}'));
$invoices_table->add(new core_datacolumn('from_org_name','Payment Info',false,'40%','{direction_info}','{from_org_name}','{from_org_name}'));
$invoices_table->add(new core_datacolumn('due_date','Due Date',true,'20%','{due_date}','{due_date}','{due_date}'));
$invoices_table->add(new core_datacolumn('amount_due','Amount Due',true,'14%','{amount_due}','{amount_due}','{amount_due}'));
$invoices_table->add(new core_datacolumn('invoice_id',array(core_ui::check_all('invoices'),'',''),false,'4%',core_ui::check_all('invoices','invoice_id'),' ',' '));
$invoices_table->columns[2]->autoformat='date-long';
#$invoices_table->columns[3]->autoformat='price';
$invoices_table->sort_direction='desc';


?>

<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_all_invoices">
		<?
		$invoices_table->render();
		?>
		<div class="pull-right" id="create_payment_form_toggler">
			<input type="button" onclick="core.payments.makePayments('invoices');" class="btn btn-info" value="Make Payments" />
		</div>
		<br />&nbsp;<br />
	</div>
	<div id="invoices_pay_area" style="display: none;">
		
	</div>
</div>
