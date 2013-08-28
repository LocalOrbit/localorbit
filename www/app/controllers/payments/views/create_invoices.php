<?php 
$sql = "
	SELECT 
       u.lo_oid,
       u.payment_ref,
       u.order_date,
       SUM(u.invoice_amount) AS invoice_amount
		
	FROM (
	     SELECT 
			lo_order.lo_oid,
			lo_order.payment_ref,
			lo_order.order_date,
	        payables.amount as invoice_amount
	     FROM payables INNER JOIN lo_order ON lo_order.lo_oid = payables.parent_obj_id
			INNER JOIN lo_order_line_item ON lo_order_line_item.lo_oid = lo_order.lo_oid
			LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id
			
	     WHERE invoices.invoice_id IS NULL
	           AND payables.payable_type = 'delivery fee'
	           AND lo_order_line_item.ldstat_id = 4 /* delivered */
	           AND lo_order.lbps_id = 1  /* unpaid */
	           AND payables.amount != 0
	           AND payables.to_org_id = ".$core->session['org_id']." /* Z01-mm */
	     GROUP BY lo_order.lo_oid
	     
	     UNION 
	     SELECT 
			lo_order.lo_oid,
			lo_order.payment_ref,
			lo_order.order_date,
	        SUM(payables.amount) as invoice_amount
	            
	     FROM payables INNER JOIN lo_order_line_item ON lo_order_line_item.lo_liid = payables.parent_obj_id
			INNER JOIN lo_order ON lo_order.lo_oid = lo_order_line_item.lo_oid
			LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id
	     WHERE invoices.invoice_id IS NULL
	           AND payables.payable_type = 'buyer order'
	           AND lo_order_line_item.ldstat_id = 4 /* delivered */
	           AND lo_order_line_item.lbps_id = 1  /* unpaid */ 
	           AND payables.amount != 0
	           AND payables.to_org_id = ".$core->session['org_id']." /* Z01-mm */
	     GROUP BY lo_order.lo_oid
	     ) u
	          
	GROUP BY u.lo_oid
";



$to_be_invoiced = new core_collection($sql);

$to_be_invoiced_table = new core_datatable('payables', 'payments/create_invoices', $to_be_invoiced);
$to_be_invoiced_table->sort_column = -1;
$to_be_invoiced_table->sort_direction = 'desc';


$preview_button = '<input type="button" onclick="core.payments.makeCreateInvoicePdf(\'create_invoice\', 15594, true);" class="btn btn-primary" value="Preview" />';
$preview_button = '<a class="btn btn-primary" href="/app/payments/create_invoice_pdf?lo_oid={lo_oid}&preview=true" class="btn btn-primary">Preview</a>';
$send_button = '<a class="btn btn-primary" href="/app/payments/create_invoice_pdf?lo_oid={lo_oid}&preview=false" class="btn btn-primary">Send</a>';

// Order Number 	Purchase Order Number     Buyer Order Date      Invoice Amount
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Order #', false, '14%', '{lo_oid}', '{lo_oid}', '{lo_oid}'));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'PO #', false, '14%', '{payment_ref}', '{payment_ref}', '{payment_ref}'));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Buyer Order Date', false, '14%', '{order_date}', '{order_date}', '{order_date}'));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Invoice Amount', false, '14%', '{invoice_amount}', '{invoice_amount}', '{invoice_amount}'));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Preview', false, '14%', $preview_button, '', ''));
$to_be_invoiced_table->add(new core_datacolumn('creation_date', 'Send', false, '14%', $send_button, '', ''));
?>


<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?php
		$to_be_invoiced_table->render();
	?>
</div>
