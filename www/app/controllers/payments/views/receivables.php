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
$receivables->add(new core_datacolumn('ref_nbr_sortable','Reference',true,'20%','{ref_nbr_html}','{ref_nbr_nohtml}','{ref_nbr_nohtml}'));

$receivables->add(new core_datacolumn('description_sortable','Description',true,'20%','{description_html}','{description_nohtml}','{description_nohtml}'));

if(lo3::is_market() || lo3::is_admin())
	$receivables->add(new core_datacolumn('concat_ws(\' \',from_org_name,to_org_name)','From/To',true,'10%','{direction_html}','{direction}','{direction}'));


$receivables->add(new core_datacolumn('creation_date','Order Date',true,'10%','{creation_date}','{creation_date}','{creation_date}'));

$receivables->add(new core_datacolumn('amount_owed','Amount Owed',true,'10%','{amount_owed}','{amount_owed}','{amount_owed}'));

$receivables->add(new core_datacolumn('delivery_status','Delivery',true,'10%','{delivery_status}','{delivery_status}','{delivery_status}'));
$receivables->add(new core_datacolumn('buyer_payment_status','Buyer Pmt',true,'10%','{buyer_payment_status}','{buyer_payment_status}','{buyer_payment_status}'));
$receivables->add(new core_datacolumn('seller_payment_status','Seller Pmt',true,'10%','{seller_payment_status}','{seller_payment_status}','{seller_payment_status}'));
$receivables->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));


if(lo3::is_market() || lo3::is_admin())
{
	
}
else if(lo3::is_seller())
{
	$buyer_collection = new core_collection('
		select org_id as id,name
		from organizations
		where org_id in (
			select org_id
			from lo_order
			where lo_oid in (
				select lo_oid
				from lo_order_line_item
				where seller_org_id='.$core->session['org_id'].'
				and ldstat_id<>1
			)
		)
		order by name
	');
	
	$markets = new core_collection('
		select domain_id as id,name
		from domains
		where domain_id in (
			select distinct domain_id 
			from payables
			where to_org_id='.$core->session['org_id'].'
		)
		order by name
	');
	$markets->load();
	
	
	$base = mktime(0, 0, 0, date('n'), date('j'));
	$start =  $base - (86400*30) - intval($core->session['time_offset']);
	$end = $base - intval($core->session['time_offset']) + 86399;
	
	$receivables->filter_html .= '<div style="float:right;width:410px;">'.get_inline_message($receivables->name,330).'</div>';
	$receivables->filter_html .= '<div style="float:left;width:490px;">';

	$receivables->add_filter(new core_datatable_filter('receivables_createdat1','creation_date','>','unix_date',null));
	$receivables->add_filter(new core_datatable_filter('receivables_createdat2','creation_date','<','unix_date',null));
	$receivables->filter_html .= core_datatable_filter::make_date($receivables->name,'receivables_createdat1',core_format::date($start,'short'),'Invoiced from ');
	$receivables->filter_html .= core_datatable_filter::make_date($receivables->name,'receivables_createdat2',core_format::date($end,'short'),'Invoiced to ');	

	$receivables->add_filter(new core_datatable_filter('payable_info','payable_info','~','search'));
	$receivables->filter_html .= core_datatable_filter::make_text($receivables->name,'payable_info',$receivables->filter_states[$receivables->name.'__filter__payable_info'],'Search by name or ref #');

	$receivables->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';


	$receivables->filter_html .= '<div style="float:left; width:215px;">';
	
	
	$receivables->filter_html .= '<h4>Delivery Filters</h4>';
	make_filter($receivables,'ldstat_id',array(
			'2'=>'Pending',
			'3'=>'Canceled',
			'4'=>'Delivered',
			'5'=>'Partially Delivered',
			'6'=>'Contested',
		),'Status','All',40);
	make_filter($receivables,'buyer_org_id',$buyer_collection,'To','All Organizations',40);
	
	$receivables->filter_html .= '</div>';
	$receivables->filter_html .= '<div style="float:left; width:250px;">';
	
	if($markets->__num_rows > 1)
	{
		$receivables->filter_html .= '<h4>Market Filters</h4>';
		make_filter($receivables,'domain_id',$markets,'From','All Markets',90,130);
		$receivables->filter_html .= '<br />';
	}
	
	$receivables->filter_html .= '<h4>Payment Filters</h4>';
	make_filter($receivables,'lbps_id',array(
			'1'=>'Unpaid',
			'2'=>'Paid',
			'4'=>'Partially Paid',
			'5'=>'Refunded',
			'6'=>'Manual Review',
	),'Buyer Payment','All',96,130);
	make_filter($receivables,'lsps_id',array(
			'1'=>'Unpaid',
			'2'=>'Paid',
			'3'=>'Partially Paid',
	),'Seller Payment','All',96,130);
	

	$receivables->filter_html .= '</div>';
	$receivables->filter_html .= '</div>';
}

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