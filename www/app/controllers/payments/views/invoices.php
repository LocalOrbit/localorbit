<?php
$invoices = core::model('v_invoices')
	->collection()
	->filter('amount_due', '>', 0);
	
if(lo3::is_admin())
{
}
else if (lo3::is_market())
{
	$invoices->filter('to_org_id' ,'in','(
		select org_id
		from organizations_to_domains 
		where organizations_to_domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
	)');
}
else
{
	$invoices->filter('to_org_id' ,'=',$core->session['org_id']);
}

	
$invoices->add_formatter('payable_info');
$invoices->add_formatter('payment_link_formatter');
$invoices_table = new core_datatable('invoices','payments/invoices',$invoices);
$invoices_table->add(new core_datacolumn('payable_info','Description',false,'30%',			'<b>I-{invoice_id}</b><br />{description_html}','{description}','{description}'));
$invoices_table->add(new core_datacolumn('from_org_name','Payment Info',true,'26%','From: {from_domain_name}:{from_org_name}<br />To: {to_domain_name}:{to_org_name}','{from_org_name}','{from_org_name}'));
$invoices_table->add(new core_datacolumn('due_date','Due Date',true,'10%','{due_date}','{due_date}','{due_date}'));
$invoices_table->add(new core_datacolumn('amount','Amount',true,'10%',							'{amount}','{amount}','{amount}'));
$invoices_table->add(new core_datacolumn('amount_due','Amount Due',true,'10%',			'{amount_due}','{amount_due}','{amount_due}'));
$invoices_table->columns[2]->autoformat='date-long';
$invoices_table->columns[3]->autoformat='price';
$invoices_table->columns[4]->autoformat='price';
$invoices_table->add(new core_datacolumn('invoice_id',array(core_ui::check_all('dueinvoices '),'',''),false,'4%',core_ui::check_all('dueinvoices','invoice_id'),' ',' '));

$invoices_table->add_filter(new core_datatable_filter('from_domain_id'));
$invoices_table->filter_html .= core_datatable_filter::make_select(
	'invoices',
	'from_domain_id',
	$items->filter_states['invoices__filter__from_domain_id'],
	new core_collection('select distinct from_domain_id, from_domain_name from v_invoices where to_org_id = ' . $core->session['org_id']),
	'from_domain_id',
	'from_domain_name',
	'Show from all markets',
	'width: 270px;'
);

$org_sql = 'select distinct from_org_id, from_org_name from v_invoices where to_org_id = ' . $core->session['org_id'];

$domain_id = $invoices_table->filter_states['invoices__filter__from_domain_id'];
if(is_numeric($domain_id) && $domain_id > 0)
{
   $org_sql .= ' and from_domain_id='.$invoices_table->filter_states['invoices__filter__from_domain_id'];
}

$invoices_table->add_filter(new core_datatable_filter('from_org_id'));
$invoices_table->filter_html .= core_datatable_filter::make_select(
	'invoices',
	'from_org_id',
	$items->filter_states['invoices__filter__from_org_id'],
	new core_collection($org_sql),
	'from_org_id',
	'from_org_name',
	'Show from all organizations',
	'width: 270px;'
);

?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_all_invoices">
		<?
		$invoices_table->render();
		?>
		<div class="buttonset" id="create_payment_form_toggler">
			<input type="button" onclick="core.payments.recordPayments();" class="button_primary" value="Record Payments" />
		</div>
		<br />&nbsp;<br />
	</div>
	<div id="invoices_pay_area" style="display: none;">
		
	</div>
	
</div>