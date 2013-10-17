<?php 
$invoiced_sql = "
	select distinct lo_order.lo_oid,
		lo_order.lo3_order_nbr,
		lo_order.payment_ref,
		lo_order.order_date,
        lo_order_deliveries.delivery_start_time,
		invoices.due_date,
		invoices.invoice_num,
        lo_order.grand_total AS invoice_amount
			
	from lo_order INNER JOIN invoices ON lo_order.lo_oid = invoices.lo_oid
	     INNER JOIN lo_order_deliveries ON lo_order_deliveries.lo_oid = invoices.lo_oid
	where lo_order.lbps_id = 3
	      and org_id = ".$core->session['org_id'];


      
$invoices = new core_collection($invoiced_sql);

$invoices_table = new core_datatable('view_invoices', 'payments/view_invoices', $invoices);
$invoices_table->sort_column = 4;
$invoices_table->sort_direction = 'asc';


$pdf_preview_link = '<a target="_blank" href="/app/payments/view_invoice_pdf?invoice_num={invoice_num}"><b>{invoice_num}</b></a>';

$days_diff = 

// Order Number 	Purchase Order Number     Buyer Order Date      Invoice Amount
$invoices_table->add(new core_datacolumn('invoice_num','Invoice Number',true,'15%',$pdf_preview_link,'{invoice_num}','{invoice_num}'));
$invoices_table->add(new core_datacolumn('payment_ref', 'Purchase Order Number', true, '20%', '{payment_ref}', '{payment_ref}', '{payment_ref}'));
$invoices_table->add(new core_datacolumn('order_date', 'Order Date', true, '15%', '{order_date}', '{order_date}', '{order_date}'));
$invoices_table->add(new core_datacolumn('delivery_start_time', 'Delivery Date', true, '15%', '{delivery_start_time}', '{delivery_start_time}', '{delivery_start_time}'));
$invoices_table->add(new core_datacolumn('due_date', 'Payment Due Date', true, '15%', '{due_date}', '{due_date}', '{due_date}'));
$invoices_table->add(new core_datacolumn('invoice_amount', 'Invoice Amount', true, '15%', '{invoice_amount}', '{invoice_amount}', '{invoice_amount}'));
$invoices_table->columns[2]->autoformat='date-short';
$invoices_table->columns[3]->autoformat='date-short';
$invoices_table->columns[4]->autoformat='date-short-highlight-past';
$invoices_table->columns[5]->autoformat='price';
$invoices_table->render_exporter = false;


//
		
		
// default seach dates
/* $start = Date('Y-m-d', strtotime("-30 days"));
$end = Date('Y-m-d', strtotime("+2 days"));
if(!isset($core->data[$invoices_table->name.'__filter__date1'])){
	$core->data[$invoices_table->name.'__filter__date1'] = $start;
}
if(!isset($core->data[$invoices_table->name.'__filter__date2'])){
	$core->data[$invoices_table->name.'__filter__date2'] = $end;
} */

// default dates
$base = mktime(0, 0, 0, date('n'), date('j'));
$start =  $base - (86400*30) - intval($core->session['time_offset']);
$end = $base - intval($core->session['time_offset']) + 86399;

// invoices.due_date is unix date
core_format::fix_unix_date_range(
	$invoices_table->name.'__filter__date1',
	$invoices_table->name.'__filter__date2'
);

if(!isset($core->data[$invoices_table->name.'__filter__date1'])){
	$core->data[$invoices_table->name.'__filter__date1'] = $start;
}
if(!isset($core->data[$invoices_table->name.'__filter__date2'])){
	$core->data[$invoices_table->name.'__filter__date2'] = $end;
}



// filter box ********************************************************************************************************
$invoices_table->filter_html .= '<div style="float:right;width:410px;">'.get_inline_message('view_invoice',330).'</div>';
$invoices_table->filter_html .= '<div style="float:left;width:490px;">';
	// dates
	$invoices_table->add_filter(new core_datatable_filter('date1','invoices.due_date','>','unix_date',null));
	$invoices_table->add_filter(new core_datatable_filter('date2','invoices.due_date','<','unix_date',null));
	$invoices_table->filter_html .= core_datatable_filter::make_date($invoices_table->name,'date1',core_format::date($start,'short'),'Payment Due Date Start');
	$invoices_table->filter_html .= core_datatable_filter::make_date($invoices_table->name,'date2',core_format::date($end,'short'),'Payment Due Date End');
	
	// order number	and PO number
	$invoices_table->add_filter(new core_datatable_filter('payable_info','concat(lo3_order_nbr,payment_ref)','~','search'));
	$invoices_table->filter_html .= core_datatable_filter::make_text($invoices_table->name,'payable_info',$invoices_table->filter_states[$invoices_table->name.'__filter__payable_info'],'Search by order number');
	$invoices_table->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';
$invoices_table->filter_html .= '</div>';

?>

<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?php
		$invoices_table->render();
	?>
</div>
