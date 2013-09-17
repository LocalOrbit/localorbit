<?php
class core_model_invoices extends core_model_base_invoices
{
	
	function getNextInvoiceNumber($orderId) {
		global $core;
		return $orderId.'-'.core_db::col('SELECT (COUNT(lo_oid) + 1) AS invoice_num FROM invoices WHERE lo_oid = '.$orderId, 'invoice_num');
	}
}
?>