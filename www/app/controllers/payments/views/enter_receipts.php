<?php 

$buyer_collection = new core_collection('
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
	select distinct lo_order.lo_oid,
		invoices.invoice_num,
		lo_order.payment_ref,
		organizations.name,
        lo_order.order_date,
		invoices.due_date,
        lo_order.grand_total AS invoice_amount,
		lo_order.domain_id
			
	from lo_order INNER JOIN invoices ON lo_order.lo_oid = invoices.lo_oid
	     INNER JOIN organizations ON organizations.org_id = lo_order.org_id
	     INNER JOIN payables ON  payables.lo_oid = lo_order.lo_oid
	where lo_order.lbps_id = 3 /* 3 = Invoice Issued*/
	      and payables.to_org_id = ".$core->session['org_id'];


$enter_receipts = new core_collection($sql);

$enter_receipts_table = new core_datatable('enter_receipts', 'payments/enter_receipts', $enter_receipts);
$enter_receipts_table->sort_column = 4;
$enter_receipts_table->sort_direction = 'asc';


$pdf_preview_link = '<a target="_blank" href="/app/payments/view_invoice_pdf?invoice_num={invoice_num}"><b>{invoice_num}</b></a>';


// Order Number 	Purchase Order Number     Buyer Order Date      Invoice Amount
$enter_receipts_table->add(new core_datacolumn('invoice_num','Invoice Number',true,'15%',$pdf_preview_link,'{invoice_num}','{invoice_num}'));
$enter_receipts_table->add(new core_datacolumn('payment_ref', 'Purchase Order Number', true, '20%', '{payment_ref}', '{payment_ref}', '{payment_ref}'));
$enter_receipts_table->add(new core_datacolumn('name', 'Buyer', true, '15%', '{name}', '{name}', '{name}'));
$enter_receipts_table->add(new core_datacolumn('order_date', 'Order Date', true, '15%', '{order_date}', '{order_date}', '{order_date}'));
$enter_receipts_table->add(new core_datacolumn('due_date', 'Payment Due Date', true, '15%', '{due_date}', '{due_date}', '{due_date}'));
$enter_receipts_table->add(new core_datacolumn('invoice_amount', 'Invoice Amount', true, '15%', '{invoice_amount}', '{invoice_amount}', '{invoice_amount}'));
$enter_receipts_table->add(new core_datacolumn('invoice_num',array(core_ui::check_all('invoices'),'',''),false,'4%',core_ui::check_all('invoices','invoice_num'),' ',' '));

$enter_receipts_table->columns[3]->autoformat='date-short';
$enter_receipts_table->columns[4]->autoformat='date-short-highlight-past-with-days';
$enter_receipts_table->columns[5]->autoformat='price';
$enter_receipts_table->render_exporter = false;


//
		
		
// default seach dates
/* $start = Date('Y-m-d', strtotime("-30 days"));
$end = Date('Y-m-d', strtotime("+2 days"));
if(!isset($core->data[$enter_receipts_table->name.'__filter__date1'])){
	$core->data[$enter_receipts_table->name.'__filter__date1'] = $start;
}
if(!isset($core->data[$enter_receipts_table->name.'__filter__date2'])){
	$core->data[$enter_receipts_table->name.'__filter__date2'] = $end;
} */

// default dates
$base = mktime(0, 0, 0, date('n'), date('j'));
$start =  $base - (86400*30) - intval($core->session['time_offset']);
$end = $base - intval($core->session['time_offset']) + 86399;
// invoices.due_date is unix date
core_format::fix_unix_date_range(
	$enter_receipts_table->name.'__filter__date1',
	$enter_receipts_table->name.'__filter__date2'
);
if(!isset($core->data[$enter_receipts_table->name.'__filter__date1'])){
	$core->data[$enter_receipts_table->name.'__filter__date1'] = $start;
}
if(!isset($core->data[$enter_receipts_table->name.'__filter__date2'])){
	$core->data[$enter_receipts_table->name.'__filter__date2'] = $end;
}



// filter box ********************************************************************************************************
$enter_receipts_table->filter_html .= '<div style="float:right;width:410px;">'.get_inline_message('view_invoice',330).'</div>';
$enter_receipts_table->filter_html .= '<div style="float:left;width:490px;">';
	// dates
	$enter_receipts_table->add_filter(new core_datatable_filter('date1','invoices.due_date','>','unix_date',null));
	$enter_receipts_table->add_filter(new core_datatable_filter('date2','invoices.due_date','<','unix_date',null));
	$enter_receipts_table->filter_html .= core_datatable_filter::make_date($enter_receipts_table->name,'date1',core_format::date($start,'short'),'Payment Due Date Start');
	$enter_receipts_table->filter_html .= core_datatable_filter::make_date($enter_receipts_table->name,'date2',core_format::date($end,'short'),'Payment Due Date End');
	
	// order number	and PO number
	$enter_receipts_table->add_filter(new core_datatable_filter('payable_info','concat(lo3_order_nbr,payment_ref)','~','search'));
	

	$enter_receipts_table->filter_html .= core_datatable_filter::make_text($enter_receipts_table->name,'payable_info',$enter_receipts_table->filter_states[$enter_receipts_table->name.'__filter__payable_info'],'Search by Invoice or Purchase Order Number');
	$enter_receipts_table->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';

	// buyer org	
	make_filter($enter_receipts_table,'lo_order.org_id',$buyer_collection,'Buyer','All Organizations');

	// markets
	if ($markets->__num_rows > 1) {
		make_filter($enter_receipts_table,'domain_id',$markets,'Market','All Markets');
		$enter_receipts_table->filter_html .= '<div class="clearfix">&nbsp;</div>';
	}
	
$enter_receipts_table->filter_html .= '</div>';

?>

<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div id="enter_receipts_list">
		<?php
			$enter_receipts_table->render();
		?>
		<div class="pull-right">
			<input type="button" onclick="core.payments.reSendInvoices();" class="btn btn-info" value="Resend Invoices" />
			<input type="button" onclick="core.payments.enterReceipts('enter_receipts');" class="btn btn-primary" value="Enter Receipts" />
		</div>
	</div>
	
	<div id="enter_receipts_actions" style="display: none;"></div>
</div>


