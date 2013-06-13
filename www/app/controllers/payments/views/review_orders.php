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
if(lo3::is_admin() || lo3::is_market())
{
	$payables->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','From/To',true,'13%',			'{direction_html}','{direction}','{direction}'));
}
$payables->add(new core_datacolumn('po_number','PO #',false,'10%',			'{po_number}','{po_number}','{po_number}'));
$payables->add(new core_datacolumn('creation_date','Description',false,'23%','{description_html}','{description_html}','{description_html}'));
$payables->add(new core_datacolumn('creation_date','Order Date',true,'10%','{creation_date}','{creation_date}','{creation_date}'));
$payables->add(new core_datacolumn('delivery_end_time','Deliver Date',true,'10%','{delivery_end_time_html}','{delivery_end_time_html}','{delivery_end_time_html}'));
$payables->add(new core_datacolumn('due_date','Payment Due',true,'12%','{payment_due}','{payment_due}','{payment_due}'));
$payables->add(new core_datacolumn('amount','Amount Owed',true,'8%','{amount}','{amount}','{amount}'));
#$payables->add(new core_datacolumn('status','Payment Status',true,'12%','{payment_status}','{payment_status}','{payment_status}'));
$payables->add(new core_datacolumn('payable_id',array(core_ui::check_all('payables'),'',''),false,'4%',core_ui::check_all('payables','payable_id'),' ',' '));

$payables->columns[3]->autoformat='date-short';
//$payables->columns[4]->autoformat='date-short';
$payables->columns[((lo3::is_admin() || lo3::is_market())?7:6)]->autoformat='price';
$payables->sort_column = 3 + ((lo3::is_admin() || lo3::is_market())?1:0);;
$payables->sort_direction = 'desc';
?>

<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div id="payables_list">
		<?
		$payables->render();
		?>
		<div class="pull-right" id="create_payment_button">
			<!-- this is right for buyers -->
			<!-- this is right for sellers -->
			<!-- this is right for market managers-->
			<!-- uncertain for admins -->
			<?if(lo3::is_admin() || lo3::is_self_managed()){?>
			<input type="button" onclick="core.payments.makePayments('payables');" class="btn btn-info" value="<?=$core->i18n('button:payments:'.((lo3::is_market())?'enter_offline_payments':'enter_online_payments'))?>" />
			<?}?>
		</div>
	</div>
	<div id="payables_actions" style="display: none;">
		
	</div>
</div>

