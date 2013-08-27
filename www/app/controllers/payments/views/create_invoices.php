<?php 
$sql = "
	SELECT DISTINCT 
		invoices.invoice_id,
		lo_order.lo_oid,
		lo_order.payment_ref,
		lo_order.order_date,
		SUM(payables.amount) AS invoice_amount,
		SUM(payments.amount) AS paid_invoice_amount,
		payables.from_org_id,
		payables.to_org_id,
		case when (lo_order_line_item.ldstat_id = 4) then 'delivered' else 'not delivered' end AS delivery_status
	       
	FROM lo_order INNER JOIN lo_order_line_item ON lo_order.lo_oid = lo_order_line_item.lo_oid
	     INNER JOIN payables ON (payables.parent_obj_id = lo_order.lo_oid OR payables.parent_obj_id = lo_order_line_item.lo_liid) 
	     LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id	     
	     LEFT JOIN x_payables_payments ON x_payables_payments.payable_id = payables.payable_id
	     LEFT JOIN payments ON x_payables_payments.payment_id = payments.payment_id
	     LEFT JOIN lo_order_deliveries ON lo_order_deliveries.lodeliv_id = lo_order_line_item.lodeliv_id 
	WHERE invoices.invoice_id IS NULL
		AND payables.to_org_id = ".$core->session['org_id']." /* Z01-mm */
		AND lo_order_line_item.ldstat_id = 4 /* delivered */
	GROUP BY lo_order.lo_oid
	ORDER BY lo_order.lo_oid
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
