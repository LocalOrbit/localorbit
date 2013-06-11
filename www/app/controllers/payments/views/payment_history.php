<?php
$v_payments = new core_collection('
	select * 
	from v_payments
	where (from_org_id='.$core->session['org_id'].' or to_org_id='.$core->session['org_id'].')
');
$v_payments->add_formatter('format_payable_info');

$payments = new core_datatable('payments','payments/payment_history',$v_payments);
payments__add_standard_filters($payments,'transactions');
$payments->add(new core_datacolumn('payment_date','Date Paid',true,'15%',			'{payment_date}','{payment_date}','{payment_date}'));

$autoformat_offset = 4;
if(lo3::is_admin() || lo3::is_market())
{
	$payments->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','From/To',true,'13%',			'{direction_html}','{direction}','{direction}'));
	$autoformat_offset++;
}

$payments->add(new core_datacolumn('order_date','Ref #',false,'15%',			'{ref_nbr_html}','{ref_nbr_html}','{ref_nbr_html}'));
$payments->add(new core_datacolumn('order_date','Description',false,'15%','{description_html}','{description_html}','{description_html}'));
$payments->add(new core_datacolumn('payment_method','Payment Method',true,'10%','{payment_method_html}','{payment_method_html}','{payment_method_html}'));
$payments->add(new core_datacolumn('amount','Amount',true,'10%','{amount}','{amount}','{amount}'));

$payments->add(new core_datacolumn('payment_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payment_id'),' ',' '));

#$payments->add(new core_datacolumn('payable_info','Payable Info',true,'50%','{payable_info}','{payable_info}','{payable_info}'));
$payments->columns[0]->autoformat='date-short';
$payments->columns[($autoformat_offset)]->autoformat='price';
$payments->sort_column = 0;
$payments->sort_direction = 'desc';
?>
<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?php
	$payments->render();
	?>
	<?if(lo3::is_admin()){?>
	<div class="pull-right" id="create_payment_button">
		<input type="button" onclick="core.payments.resendPaymentNotification();" class="btn btn-primary" value="Re-send Notification E-mail" />
	</div>
	<?}?>
</div>