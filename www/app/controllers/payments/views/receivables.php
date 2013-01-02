<?php
$payables = core::model('v_payables')
	->collection()
	->filter('amount_due','>',0)
	->filter('is_invoiced','=',0);

if(lo3::is_market())
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
}
else if (!lo3::is_admin())
{
	$payables->filter('to_org_id','=',$core->session['org_id']);
}

$payables->add_formatter('payable_info');
$payables->add_formatter('payment_link_formatter');
$payables->add_formatter('payment_direction_formatter');
$payables_table = new core_datatable('receivables','payments/receivables',$payables);
$payables_table->add(new core_datacolumn('payable_id','Description',true,'22%',			'<b>R-{payable_id}</b><br />{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn(null,'Payment Info',false,'34%','{direction_info}','{direction_info}','{direction_info}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'12%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn('amount_due','Amount',true,'14%',							'{amount_due}','{amount_due}','{amount_due}'));
$payables_table->add(new core_datacolumn('last_sent','Last Sent',true,'14%',							'{last_sent}','{last_sent}','{last_sent}'));
$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));
$payables_table->columns[2]->autoformat='date-long';
$payables_table->columns[3]->autoformat='price';
$payables_table->columns[4]->autoformat='date-long';

$payables_table->add_filter(new core_datatable_filter('to_domain_id'));
$payables_table->filter_html .= core_datatable_filter::make_select(
	'receivables',
	'to_domain_id',
	$items->filter_states['receivables__filter__to_domain_id'],
	new core_collection('select distinct to_domain_id, to_domain_name from v_payables where to_org_id = ' . $core->session['org_id'] . ';'),
	'to_domain_id',
	'to_domain_name',
	'Filter by Hub: All Hubs',
	'width: 270px;'
);

$payables_table->add_filter(new core_datatable_filter('from_org_id'));
$payables_table->filter_html .= core_datatable_filter::make_select(
	'receivables',
	'from_org_id',
	$items->filter_states['receivables__filter__from_org_id'],
	new core_collection('select distinct from_org_id, from_org_name from v_payables where to_org_id = ' . $core->session['org_id'] . ';'),
	'from_org_id',
	'from_org_name',
	'Show from all organizations',
	'width: 270px;'
);
?>

<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_receivables">
		<?php
		$payables_table->render();
		
		if($payables->__num_rows > 0)
		{
		?>
		<div class="buttonset" id="create_invoice_toggler">
			<input type="button" onclick="core.payments.getCreatePaymentsForm('receivables');" value="pay checked" class="button_primary" />
			<input type="button" onclick="core.payments.getCreateInvoicesForm();" value="create invoice from checked" class="button_primary" />
		</div>
		<?}?>
	<br />&nbsp;<br />
	</div>
	<div id="receivables_create_area" style="display: none;">
		
	</div>
</div>