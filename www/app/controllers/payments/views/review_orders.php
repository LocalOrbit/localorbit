<?php
$v_payables = core::model('v_payables')->collection();
$v_payables->add_formatter('format_payable_info');
if(!lo3::is_admin())
{
	$v_payables->filter('from_org_id','=',$core->session['org_id']);
}
$payables = new core_datatable('payables','payments/review_orders',$v_payables);
payments__add_standard_filters($payables,'payables');
$payables->add(new core_datacolumn('creation_date','Ref #',false,'14%',			'{ref_nbr_html}','{ref_nbr_html}','{ref_nbr_html}'));
$payables->add(new core_datacolumn('creation_date','Description',false,'28%','{description_html}','{description_html}','{description_html}'));
$payables->add(new core_datacolumn('creation_date','Order Date',true,'11%','{creation_date}','{creation_date}','{creation_date}'));
$payables->add(new core_datacolumn('delivery_end_time','Deliver Date',true,'11%','{delivery_end_time}','{delivery_end_time}','{delivery_end_time}'));
$payables->add(new core_datacolumn('due_date','Payment Due',true,'15%','{payment_due}','{payment_due}','{payment_due}'));
$payables->add(new core_datacolumn('amount','Amount',true,'8%','{amount}','{amount}','{amount}'));
$payables->add(new core_datacolumn('status','Payment Status',true,'13%','{payment_status}','{payment_status}','{payment_status}'));
$payables->columns[2]->autoformat='date-short';
$payables->columns[3]->autoformat='date-short';
$payables->columns[5]->autoformat='price';
?>
<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?
	$payables->render();
	?>
</div>