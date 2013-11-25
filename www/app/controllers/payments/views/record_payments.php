<?php

$seller_collection = new core_collection('
	select DISTINCT organizations.org_id as id, organizations.name
	from organizations INNER JOIN lo_order ON organizations.org_id = lo_order.org_id
	     INNER JOIN payables ON payables.lo_oid = lo_order.lo_oid
	where payables.to_org_id = '.$core->session['org_id'].'
	order by organizations.name
');


$markets_sql = 'select domain_id as id,name from domains
		where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).') ';
$markets = new core_collection($markets_sql);


$sql = "
	select 
		organizations.name as seller_name,
		lo_order.lo_oid,
		lo_order.lo3_order_nbr,
		lo_order_line_item.product_name,
		lo_order_line_item.qty_delivered,
		lo_order.order_date,
	    if((lo_order_deliveries.pickup_end_time = 0),
	    FROM_UNIXTIME(lo_order_deliveries.delivery_end_time),
	    FROM_UNIXTIME(lo_order_deliveries.pickup_end_time)) AS delivery_end_time,
		payables.amount,
		payables.payable_id
	from lo_order INNER JOIN lo_order_line_item ON lo_order_line_item.lo_oid = lo_order.lo_oid
		INNER JOIN payables ON payables.lo_liid = lo_order_line_item.lo_liid 		
		INNER JOIN organizations ON organizations.org_id = payables.to_org_id
		INNER JOIN lo_order_deliveries ON lo_order_deliveries.lodeliv_id = lo_order_line_item.lodeliv_id
		LEFT JOIN x_payables_payments ON x_payables_payments.payable_id = payables.payable_id
  	where x_payables_payments.xpp_id IS NULL
		and payables.from_org_id = ".$core->session['org_id']."
	    and payable_type = 'seller order'
	    and lo_order_line_item.ldstat_id != 3 /*cancelled*/";

$payments = new core_collection($sql);



$payments_table = new core_datatable('record_payments','payments/record_payments',$payments);
$payments_table->add(new core_datacolumn('seller_name', 'Seller', true, '15%', '{seller_name}', '{seller_name}', '{seller_name}'));
$payments_table->add(new core_datacolumn('lo3_order_nbr', 'Order Number', true, '20%', '<a href="#!orders-view_order--lo_oid-{lo_oid}"><b>{lo3_order_nbr}</b></a>', '{lo3_order_nbr}', '{lo3_order_nbr}'));
$payments_table->add(new core_datacolumn('product_name', 'Description', true, '25%', '{product_name} ({qty_delivered})', '{product_name}', '{product_name}'));
$payments_table->add(new core_datacolumn('order_date','Order Date',true,'12%','{order_date}','{order_date}','{order_date}'));
$payments_table->add(new core_datacolumn('delivery_end_time','Delivery Date',true,'12%','{delivery_end_time}','{delivery_end_time}','{delivery_end_time}'));
$payments_table->add(new core_datacolumn('amount', 'Amount', true, '12%', '{amount}', '{amount}', '{amount}'));

$payments_table->columns[3]->autoformat='date-short';
$payments_table->columns[4]->autoformat='date-short';
$payments_table->columns[5]->autoformat='price';
$payments_table->render_exporter = false;

$payments_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('payments'),'',''),false,'4%',core_ui::check_all('payments','payable_id'),' ',' '));




// default dates
$start = Date('Y-m-d', strtotime("-30 days"));
$end = Date('Y-m-d', strtotime("+2 days"));
if(!isset($core->data[$payments_table->name.'__filter__date1'])){
	$core->data[$payments_table->name.'__filter__date1'] = $start;
}
if(!isset($core->data[$payments_table->name.'__filter__date2'])){
	$core->data[$payments_table->name.'__filter__date2'] = $end;
}





// filter box ********************************************************************************************************
$payments_table->filter_html .= '<div style="float:right;width:410px;">'.get_inline_message('view_invoice',330).'</div>';
$payments_table->filter_html .= '<div style="float:left;width:490px;">';
// dates
$payments_table->add_filter(new core_datatable_filter('date1','lo_order.order_date','>','unix_date',null));
$payments_table->add_filter(new core_datatable_filter('date2','lo_order.order_date','<','unix_date',null));
$payments_table->filter_html .= core_datatable_filter::make_date($payments_table->name,'date1',core_format::date($start,'short'),'Order Date From');
$payments_table->filter_html .= core_datatable_filter::make_date($payments_table->name,'date2',core_format::date($end,'short'),'Order Date To');

// order number	and PO number
$payments_table->add_filter(new core_datatable_filter('payable_info','concat(lo3_order_nbr,payment_ref)','~','search'));


$payments_table->filter_html .= core_datatable_filter::make_text($payments_table->name,'payable_info',$payments_table->filter_states[$payments_table->name.'__filter__payable_info'],'Search by Invoice or Purchase Order Number');
$payments_table->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';

// buyer org
make_filter($payments_table,'lo_order.org_id',$seller_collection,'Seller','All Organizations');


// markets
if ($markets->__num_rows > 1) {
	make_filter($enter_receipts_table,'domain_id',$markets,'Market','All Markets');
	$enter_receipts_table->filter_html .= '<div class="clearfix">&nbsp;</div>';
}

$payments_table->filter_html .= '</div>';

?>


<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div id="payments_list">
		<?
		$payments_table->render();
		?>
		<div class="pull-right" id="create_payment_button">
			<!-- this is right for buyers -->
			<!-- this is right for sellers -->
			<!-- this is right for market managers-->
			<!-- uncertain for admins -->
			<?if(lo3::is_admin() || lo3::is_self_managed() || lo3::is_fully_managed_customer()){?>
			<input type="button" onclick="core.payments.recordPayments('payments');" class="btn btn-info" value="<?=$core->i18n('button:payments:enter_offline_payments')?>" />
			<?}?>
		</div>
	</div>
	<div id="payments_actions" style="display: none;">
		
	</div>
</div>

