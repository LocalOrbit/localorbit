<?php
class core_model_invoices extends core_model_base_invoices
{
	
	function getNextInvoiceNumber($lo_oid) {
		global $core;
		return $lo_oid.'-'.core_db::col('SELECT (COUNT(lo_oid) + 1) AS invoice_num FROM invoices WHERE lo_oid = '.$lo_oid, 'invoice_num');
	}
	
	
	function createInvoiceWithPayableIds($lo_oid, $invoice_num, $payable_ids, $due_date) {	
		global $core;
			
		// save invoice
		$invoice = core::model('invoices');
		$invoice['first_invoice_date'] = time();
		$invoice['creation_date'] = time();
		$invoice['due_date'] = $due_date;
		$invoice['lo_oid'] = $lo_oid;
		$invoice['invoice_num'] = $invoice_num;
		$invoice->save();

		// update payables.invoice_id
		$payable_ids[] = 0; // make sure not empty list		
		$sql = "UPDATE payables SET invoice_id = ".$invoice['invoice_id']." WHERE payable_id IN (".implode(",", $payable_ids).")";
		core_db::query($sql);
		
		return $invoice;
	}
}
?>