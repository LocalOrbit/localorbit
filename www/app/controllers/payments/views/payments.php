<?php
$payments_owed = core::model('v_invoices')
	->collection()
	->filter('amount_due', '>', 0);
	
if(lo3::is_admin())
{
}
else if (lo3::is_market())
{
	$payments_owed->filter('to_org_id' ,'in','(
		select org_id
		from organizations_to_domains 
		where organizations_to_domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
	)');
}
else
{
	$payments_owed->filter('from_org_id' , $core->session['org_id']);
}
$payments_owed->add_formatter('payable_info');
$payments_owed->add_formatter('payment_link_formatter');
$payments_owed->add_formatter('payment_direction_formatter');
$payments_table = new core_datatable('payments','payments/payments',$payments_owed);
$payments_table->add(new core_datacolumn('invoice_id','Description',false,'22%',			'<b>I-{invoice_id}</b><br />{description_html}','{description}','{description}'));
$payments_table->add(new core_datacolumn('from_org_name','Payment Info',true,'34%','{direction_info}','{to_org_name}','{to_org_name}'));
$payments_table->add(new core_datacolumn('creation_date','Date',true,'12%','{creation_date}','{creation_date}','{creation_date}'));
$payments_table->add(new core_datacolumn('amount','Amount',true,'28%',							'{amount}','{amount}','{amount}'));
$payments_table->add(new core_datacolumn('payment_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));
//$invoices_table->add(new core_datacolumn('amount_due','Amount Due',true,'19%',			'{amount_due}','{amount_due}','{amount_due}'));
$payments_table->columns[2]->autoformat='date-long';
$payments_table->columns[3]->autoformat='price';

$payments_table->add_filter(new core_datatable_filter('to_org_id'));
$payments_table->filter_html .= core_datatable_filter::make_select(
	'payments',
	'lo_order.org_id',
	$items->filter_states['payments__filter__from_org_id'],
	new core_collection('select distinct from_org_id, from_org_name from v_payments where from_org_id = ' . $core->session['org_id'] . ';'),
	'from_org_id',
	'from_org_name',
	'Show from all buyers',
	'width: 270px;'
);
?>
<div class="tabarea" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_all_payments">
		<?
		$payments_table->render();
		?>
		<div class="buttonset" id="create_payment_button">
			<input type="button" onclick="core.payments.makePayments();" class="button_primary" value="Make Payment" />
		</div>
	</div>
	
	<br />&nbsp;<br />
	<div id="payments_pay_area" style="display: none;">
		
	</div>
	<? 
	#$this->payments__pay_payment();
	
	?>
</div>
