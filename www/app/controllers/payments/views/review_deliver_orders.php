<?php
$v_payables = core::model('v_payables')->collection();
$v_payables->add_formatter('format_payable_info');
if(lo3::is_admin())
{
}
else if(lo3::is_market())
{
	$v_payables->filter('to_org_id','in',array(1,$core->session['org_id']));
	$v_payables->filter('domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}
else
{
	$v_payables->filter('to_org_id','=',$core->session['org_id']);
}
#echo('<pre>');
#print_r($v_payables);
#echo('</pre>');
$autoformat_offset = 2;
$receivables = new core_datatable('receivables','payments/review_deliver_orders',$v_payables);
payments__add_standard_filters($receivables,'receivables');
$receivables->add(new core_datacolumn('creation_date','Ref #',false,'13%',			'{ref_nbr_html}','{ref_nbr_html}','{ref_nbr_html}'));
if(lo3::is_admin() || lo3::is_market())
{
	$receivables->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','From/To',true,'13%',			'{direction_html}','{direction}','{direction}'));
	$autoformat_offset++;
}
$receivables->add(new core_datacolumn('creation_date','Description',false,'15%','{description_html}','{description_html}','{description_html}'));

$receivables->add(new core_datacolumn('creation_date','Order Date',true,'10%','{creation_date}','{creation_date}','{creation_date}'));
$receivables->columns[$autoformat_offset]->autoformat='date-short';

$receivables->add(new core_datacolumn('delivery_end_time','Deliver Date',true,'10%','{delivery_end_time}','{delivery_end_time}','{delivery_end_time}'));
$receivables->columns[($autoformat_offset+1)]->autoformat='date-short';

# only MMs and admins need this column
if(lo3::is_admin() || lo3::is_market())
{
	$receivables->add(new core_datacolumn('due_date','Payment Due',true,'12%','{payment_due}{last_sent}','{payment_due}{last_sent}','{payment_due}{last_sent}'));
	$autoformat_offset++;
	$receivables->columns[($autoformat_offset+1)]->autoformat='date-short';
}

$receivables->add(new core_datacolumn('amount','Amount Owed',true,'10%','{amount}','{amount}','{amount}'));
$receivables->add(new core_datacolumn('receivable_status','Status',true,'10%','{receivable_status}','{receivable_status}','{receivable_status}'));
$receivables->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));





$receivables->columns[($autoformat_offset+2)]->autoformat='price';
$receivables->sort_column = 2 + ((lo3::is_admin() || lo3::is_market())?1:0);
$receivables->sort_direction = 'desc';

?>
<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div id="receivables_list">
		<?php
		$receivables->render();
		?>
		<div class="pull-right">
			<input type="button" onclick="core.payments.markItemsDelivered();" class="btn" value="<?=$core->i18n('button:payments:mark_items_delivered')?>" />
			<?if(lo3::is_admin() || lo3::is_market()){?>
				<input type="button" onclick="core.payments.makePayments('receivables');" class="btn btn-info" value="<?=$core->i18n('button:payments:enter_offline_payments')?>" />
				<input type="button" onclick="core.payments.sendInvoices();" class="btn btn-primary" value="<?=$core->i18n('button:payments:send_invoices')?>" />
			<?}?>
		</div>
	</div>
	<div id="receivables_actions" style="display: none;">
		
	</div>
</div>