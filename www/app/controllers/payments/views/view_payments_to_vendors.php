<?php

$sellers = new core_collection('
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
	select distinct
		organizations.name as seller_name,
		lo_order.lo_oid,
   		invoices.invoice_num,
		lo_order.order_date,
	    if((lo_order_deliveries.pickup_end_time = 0),
	    FROM_UNIXTIME(lo_order_deliveries.delivery_end_time),
	    FROM_UNIXTIME(lo_order_deliveries.pickup_end_time)) AS delivery_end_time,
		SUM(payables.amount) AS amount
	from lo_order INNER JOIN lo_order_line_item ON lo_order_line_item.lo_oid = lo_order.lo_oid
		INNER JOIN payables ON payables.lo_liid = lo_order_line_item.lo_liid 	
		INNER JOIN invoices ON invoices.invoice_id = payables.invoice_id	
		INNER JOIN organizations ON organizations.org_id = payables.to_org_id
		INNER JOIN lo_order_deliveries ON lo_order_deliveries.lodeliv_id = lo_order_line_item.lodeliv_id
		LEFT JOIN x_payables_payments ON x_payables_payments.payable_id = payables.payable_id
  	where x_payables_payments.xpp_id IS NULL
		and payables.from_org_id in (1,".$core->session['org_id'].")
and lo_order.domain_id in ('30','19')				
	    and payable_type = 'seller order'
		and lo_order.lbps_id = 2 /* paid * /
	    and lo_order_line_item.ldstat_id != 3 /*cancelled*/";

$payments = new core_collection($sql);
$payments->group('invoices.invoice_num');


$pdf_preview_link = '<a target="_blank" href="/app/payments/view_invoice_pdf?invoice_num={invoice_num}"><b>{invoice_num}</b></a>';
$payments_table = new core_datatable('view_payments_to_vendors','payments/view_payments_to_vendors',$payments);

$payments_table->add(new core_datacolumn('invoice_num', 'Invoice Number', true, '25%', $pdf_preview_link, '{invoice_num}', '{invoice_num}'));
$payments_table->add(new core_datacolumn('seller_name', 'Seller', true, '20%', '{seller_name}', '{seller_name}', '{seller_name}'));
$payments_table->add(new core_datacolumn('order_date','Order Date',true,'17%','{order_date}','{order_date}','{order_date}'));
$payments_table->add(new core_datacolumn('delivery_end_time','Delivery Date',true,'17%','{delivery_end_time}','{delivery_end_time}','{delivery_end_time}'));
$payments_table->add(new core_datacolumn('amount', 'Amount', true, '17%', '{amount}', '{amount}', '{amount}'));

$payments_table->columns[2]->autoformat='date-short';
$payments_table->columns[3]->autoformat='date-short';
$payments_table->columns[4]->autoformat='price';
$payments_table->render_exporter = false;

$payments_table->sort_column = 2;
$payments_table->sort_direction = 'desc';



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
make_filter($payments_table,'lo_order.org_id',$sellers,'Seller','All Organizations');


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
	</div><div id="payments_actions" style="display: none;">
		
	</div>
</div>

