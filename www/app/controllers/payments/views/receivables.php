<?php

global $core;

$payables = core::model('v_payables')
	->collection()
	->filter('amount_due','>',0)
	->filter('is_invoiced','=',0);

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
		->filter('organizations.org_id','in','(select distinct to_org_id from v_payables)')
		->sort('name');
	$org_from_filters  = core::model('organizations')
		->collection()
		->filter('organizations.org_id','in','(select distinct from_org_id from v_payables)')
		->sort('name');
}
else if(lo3::is_market())
{
	$payables->filter(
			'to_org_id' ,
			'in',
			'(
			select org_id
			 from organizations_to_domains
			where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
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
		->filter('organizations.org_id','in','(select distinct to_org_id from v_payables)')
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
		->filter('organizations.org_id','in','(select distinct from_org_id from v_payables)')
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
	$payables->filter('to_org_id','=',$core->session['org_id']);
}

$payables->add_formatter('payable_info');
$payables->add_formatter('payment_link_formatter');
$payables->add_formatter('payment_direction_formatter');
$payables_table = new core_datatable('receivables','payments/receivables',$payables);
$payables_table = payments_add_standard_filters($payables_table, $hub_from_filters, $hub_to_filters, $org_from_filters, $org_to_filters, false, false); // $core->session['org_id'] != 1 ? true : false to preselect filter for non-admins?
$payables_table->add(new core_datacolumn('payable_id','Description',true,'22%',			'<b>R-{payable_id}</b><br />{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn(null,'Payment Info',false,'40%','{direction_info}','{direction_info}','{direction_info}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'20%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',true,'14%',							'{amount_due}','{amount_due}','{amount_due}'));
$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));
$payables_table->columns[2]->autoformat='date-long';
$payables_table->columns[3]->autoformat='price';
$payables_table->sort_direction='desc';

?>

<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_receivables">
		<?php
			$payables_table->render();
		?>
		<div class="pull-right" id="create_invoice_toggler">
			<input type="button" onclick="core.payments.getCreateInvoicesForm();" value="create invoice from checked" class="btn btn-info" />
		</div>
		<br />&nbsp;<br />
	</div>
	<div id="receivables_create_area" style="display: none;">
	</div>
</div>
