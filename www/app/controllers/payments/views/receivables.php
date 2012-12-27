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

$payables->add_formatter('payable_desc');

$payables_table = new core_datatable('receivables','payments/receivables',$payables);
$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));
$payables_table->add(new core_datacolumn('description','Description',false,'32%',			'<b>R-{payable_id}</b><br />Order #: {description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'12%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn('hub_name','Market',false,'12%','{to_domain_name}','{to_domain_name}','{to_domain_name}'));
$payables_table->add(new core_datacolumn('from_org_name','Organization',false,'15%','{from_org_name}','{from_org_name}','{from_org_name}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',false,'10%',							'{payable_amount}','{payable_amount}','{payable_amount}'));
$payables_table->add(new core_datacolumn('invoice_status','Status',false,'10%',							'{invoice_status}','{invoice_status}','{invoice_status}'));
$payables_table->add(new core_datacolumn('last_sent','Last Sent',false,'10%',							'{last_sent}','{last_sent}','{last_sent}'));
$payables_table->columns[2]->autoformat='date-short';
$payables_table->columns[4]->autoformat='price';
$payables_table->columns[6]->autoformat='date-short';

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
			<input type="button" onclick="core.payments.getCreateInvoicesForm();" style="width:300px;" value="create invoice from checked" class="button_primary" />
		</div>
		<?}?>
	<br />&nbsp;<br />
	</div>
	<div id="receivables_create_area" style="display: none;">
		
	</div>
</div>