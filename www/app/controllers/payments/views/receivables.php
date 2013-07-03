<?php

$v_payables = core::model('v_payables_4071')->collection();
$v_payables->add_formatter('new_format_payable_info');

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

$receivables = new core_datatable('receivables','payments/receivables',$v_payables);
$receivables->add(new core_datacolumn('ref_nbr_sortable','Ref Nbr',true,'10%','{ref_nbr_html}','{ref_nbr_nohtml}','{ref_nbr_nohtml}'));

$receivables->add(new core_datacolumn('description_sortable','Description',true,'10%','{description_html}','{description_nohtml}','{description_nohtml}'));

if(lo3::is_market() || lo3::is_admin())
	$receivables->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','From/To',true,'10%','{direction_html}','{direction}','{direction}'));


$receivables->add(new core_datacolumn('creation_date','Order Date',true,'10%','{creation_date}','{creation_date}','{creation_date}'));

$receivables->add(new core_datacolumn('(amount - amount_paid)','Amount Owed',true,'10%','{amount_owed}','{amount_owed}','{amount_owed}'));

$receivables->add(new core_datacolumn('delivery_status','Delivery',true,'10%','{delivery_status}','{delivery_status}','{delivery_status}'));
$receivables->add(new core_datacolumn('buyer_payment_status','Buyer Pmt',true,'10%','{buyer_payment_status}','{buyer_payment_status}','{buyer_payment_status}'));
$receivables->add(new core_datacolumn('seller_payment_status','Seller Pmt',true,'10%','{seller_payment_status}','{seller_payment_status}','{seller_payment_status}'));



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