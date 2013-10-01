<?php 
$sql = "
	 SELECT 
		lo_order.lo_oid,
		lo_order.lo3_order_nbr,
		lo_order.payment_ref,
		lo_order.order_date,
		lo_order.lbps_id,
		lo_order.ldstat_id,
        (lo_order.grand_total) AS invoice_amount,
		organizations.name AS buyer_name
            
    FROM payables INNER JOIN lo_order ON payables.lo_oid = lo_order.lo_oid
		LEFT JOIN lo_order_line_item ON lo_order_line_item.lo_liid = payables.lo_liid   
		INNER JOIN organizations ON organizations.org_id = lo_order.org_id
		
     WHERE lo_order.ldstat_id = 4 /* delivered */
		AND lo_order.lbps_id IN (1,4) /* unpaid or item canceled */ 
		AND payables.amount != 0
		AND payables.payable_type IN('buyer order', 'delivery fee')
		AND payables.to_org_id = ".$core->session['org_id']." /* Z01-mm */
				
     GROUP BY lo_order.lo_oid
";



$to_be_invoiced = new core_collection($sql);

$to_be_invoiced_table = new core_datatable('create_invoices', 'payments/create_invoices', $to_be_invoiced);
$to_be_invoiced_table->sort_column = -1;
$to_be_invoiced_table->sort_direction = 'desc';


//$preview_button = '<a class="btn btn-primary" href="/app/payments/create_invoice_pdf?lo_oid={lo_oid}&preview=true" class="btn btn-primary">Preview</a>';
//$send_button = '<a class="btn btn-primary" href="/app/payments/create_invoice_pdf?lo_oid={lo_oid}&preview=false" class="btn btn-primary">Send</a>';


$preview_button = '<input type="button" class="btn btn-primary" onclick="core.doRequest(\'/payments/create_invoice_loader_pdf\',{\'lo_oid\':{lo_oid},\'preview\':true});" value="Preview" />';
$send_button = '<input type="button" class="btn btn-primary" onclick="core.doRequest(\'/payments/create_invoice_loader_pdf\',{\'lo_oid\':{lo_oid},\'preview\':false});" value="Send" />';


// Order Number 	Purchase Order Number     Buyer Order Date      Invoice Amount
$to_be_invoiced_table->add(new core_datacolumn('order_date','Order #',true,'19%','<a href="#!orders-view_order--lo_oid-{lo_oid}"><b>{lo3_order_nbr}</b></a>','{lo3_order_nbr}','{lo3_order_nbr}'));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Purchase Order Number', false, '14%', '{payment_ref}', '{payment_ref}', '{payment_ref}'));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Buyer', false, '14%', '{buyer_name}', '{buyer_name}', '{buyer_name}'));
$to_be_invoiced_table->add(new core_datacolumn('order_date', 'Order Date', false, '14%', '{order_date}', '{order_date}', '{order_date}'));
$to_be_invoiced_table->add(new core_datacolumn('invoice_amount', 'Invoice Amount', false, '14%', '{invoice_amount}', '{invoice_amount}', '{invoice_amount}'));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Preview', false, '14%', $preview_button, '', ''));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Send', false, '14%', $send_button, '', ''));
$to_be_invoiced_table->columns[3]->autoformat='date-short';
$to_be_invoiced_table->columns[4]->autoformat='price';
$to_be_invoiced_table->render_exporter = false;
?>

<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?php
		$to_be_invoiced_table->render();
	?>
</div>
