<?php 

$buyer_collection = new core_collection('
	select DISTINCT organizations.org_id as id, organizations.name
	from organizations INNER JOIN lo_order ON organizations.org_id = lo_order.org_id
	     INNER JOIN payables ON payables.lo_oid = lo_order.lo_oid
	where payables.to_org_id = '.$core->session['org_id'].' 
	order by organizations.name
');


$to_be_invoiced_sql = "
	select distinct
		lo_order.lo_oid,
		lo_order.lo3_order_nbr,
		lo_order.payment_ref,
		lo_order.order_date,
		lo_order.lbps_id,
		lo_order.ldstat_id,
		lo_order.org_id,
        (lo_order.grand_total) AS invoice_amount,
		organizations.name AS buyer_name
            
    from payables INNER JOIN lo_order ON payables.lo_oid = lo_order.lo_oid
		LEFT JOIN lo_order_line_item ON lo_order_line_item.lo_liid = payables.lo_liid   
		INNER JOIN organizations ON organizations.org_id = lo_order.org_id
	where lo_order.ldstat_id = 4 /* delivered */
		AND lo_order.lbps_id IN (1,4) /* unpaid or item canceled */ 
		AND payables.amount != 0
		AND payables.payable_type IN('buyer order', 'delivery fee')
		AND payables.to_org_id = ".$core->session['org_id']." 
		AND lo_order.org_id > 0
";


$to_be_invoiced = new core_collection($to_be_invoiced_sql);

$to_be_invoiced_table = new core_datatable('create_invoices', 'payments/create_invoices', $to_be_invoiced);
$to_be_invoiced_table->sort_column = -1;
$to_be_invoiced_table->sort_direction = 'desc';


//$preview_button = '<a class="btn btn-primary" href="/app/payments/create_invoice_pdf?lo_oid={lo_oid}&preview=true" class="btn btn-primary">Preview</a>';
//$send_button = '<a class="btn btn-primary" href="/app/payments/create_invoice_pdf?lo_oid={lo_oid}&preview=false" class="btn btn-primary">Send</a>';


$preview_button = '<input type="button" class="btn btn-primary" onclick="core.doRequest(\'/payments/create_invoice_loader_pdf\',{\'lo_oid\':{lo_oid},\'preview\':true});" value="Preview" />';
$send_button = '<input type="button" class="btn btn-primary" onclick="core.doRequest(\'/payments/create_invoice_loader_pdf\',{\'lo_oid\':{lo_oid},\'preview\':false});" value="Send" />';


// Order Number 	Purchase Order Number     Buyer Order Date      Invoice Amount
$to_be_invoiced_table->add(new core_datacolumn('lo3_order_nbr','Order #',true,'19%','<a href="#!orders-view_order--lo_oid-{lo_oid}"><b>{lo3_order_nbr}</b></a>','{lo3_order_nbr}','{lo3_order_nbr}'));
$to_be_invoiced_table->add(new core_datacolumn('payment_ref', 'Purchase Order Number', true, '14%', '{payment_ref}', '{payment_ref}', '{payment_ref}'));
$to_be_invoiced_table->add(new core_datacolumn('buyer_name', 'Buyer', true, '14%', '{buyer_name}', '{buyer_name}', '{buyer_name}'));
$to_be_invoiced_table->add(new core_datacolumn('order_date', 'Order Date', true, '14%', '{order_date}', '{order_date}', '{order_date}'));
$to_be_invoiced_table->add(new core_datacolumn('invoice_amount', 'Invoice Amount', true, '14%', '{invoice_amount}', '{invoice_amount}', '{invoice_amount}'));
$to_be_invoiced_table->add(new core_datacolumn('', 'Preview', false, '14%', $preview_button, '', ''));
$to_be_invoiced_table->add(new core_datacolumn('', 'Send', false, '14%', $send_button, '', ''));
$to_be_invoiced_table->columns[3]->autoformat='date-short';
$to_be_invoiced_table->columns[4]->autoformat='price';
$to_be_invoiced_table->render_exporter = false;

// default seach dates
$start = Date('Y-m-d', strtotime("-30 days"));
$end = Date('Y-m-d', strtotime("1 days"));
if(!isset($core->data[$to_be_invoiced_table->name.'__filter__receivables_createdat1'])){
	$core->data[$to_be_invoiced_table->name.'__filter__receivables_createdat1'] = $start;
}
if(!isset($core->data[$to_be_invoiced_table->name.'__filter__receivables_createdat2'])){
	$core->data[$to_be_invoiced_table->name.'__filter__receivables_createdat2'] = $end;
}



// filter box ********************************************************************************************************
$to_be_invoiced_table->filter_html .= '<div style="float:right;width:410px;">'.get_inline_message('receivables',330).'</div>';
$to_be_invoiced_table->filter_html .= '<div style="float:left;width:490px;">';
	// dates
	$to_be_invoiced_table->add_filter(new core_datatable_filter('receivables_createdat1','lo_order.order_date','>','date',null));
	$to_be_invoiced_table->add_filter(new core_datatable_filter('receivables_createdat2','lo_order.order_date','<','date',null));
	$to_be_invoiced_table->filter_html .= core_datatable_filter::make_date($to_be_invoiced_table->name,'receivables_createdat1',core_format::date($start,'short'),'Ordered from ');
	$to_be_invoiced_table->filter_html .= core_datatable_filter::make_date($to_be_invoiced_table->name,'receivables_createdat2',core_format::date($end,'short'),'Ordered to ');
	
	// order number
	$to_be_invoiced_table->add_filter(new core_datatable_filter('payable_info','lo3_order_nbr','~','search'));
	$to_be_invoiced_table->filter_html .= core_datatable_filter::make_text($to_be_invoiced_table->name,'payable_info',$to_be_invoiced_table->filter_states[$to_be_invoiced_table->name.'__filter__payable_info'],'Search by name or ref #');
	$to_be_invoiced_table->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';

	// buyer org
	make_filter($to_be_invoiced_table,'lo_order.org_id',$buyer_collection,'Buyer','All Organizations',50);
	
	$to_be_invoiced_table->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';
$to_be_invoiced_table->filter_html .= '</div>';

?>

<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?php
		$to_be_invoiced_table->render();
	?>
</div>
