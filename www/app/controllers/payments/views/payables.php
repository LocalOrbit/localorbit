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
$payments_table = new core_datatable('payables','payments/payables',$payments_owed);
$payments_table = payments__add_standard_filters($payments_table,'payments');
$payments_table->add(new core_datacolumn('invoice_id','Description',true,'22%',			'<b>I-{invoice_id}</b><br />{description_html}','{description}','{description}'));
$payments_table->add(new core_datacolumn('from_org_name','Payment Info',false,'40%','{direction_info}','{to_org_name}','{to_org_name}'));
$payments_table->add(new core_datacolumn('creation_date','Date',true,'20%','{creation_date}','{creation_date}','{creation_date}'));
$payments_table->add(new core_datacolumn('amount_due','Amount',true,'14%',							'{amount_due}','{amount_due}','{amount_due}'));
$payments_table->add(new core_datacolumn('payment_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','invoice_id'),' ',' '));
$payments_table->columns[2]->autoformat='date-long';
#$payments_table->columns[3]->autoformat='price';
$payments_table->sort_direction='desc';

?>

<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_all_payments">
		<?
		$payments_table->render();
		?>
		<div class="pull-right" id="create_payment_button">
			<input type="button" onclick="core.payments.makePayments('payments');" class="btn btn-info" value="Make Payment" />
		</div>
	</div>
	
	<br />&nbsp;<br />
	<div id="payments_pay_area" style="display: none;">
		
	</div>
	<? 
	#$this->payments__pay_payment();
	
	?>
</div>
