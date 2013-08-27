<?php
class core_model_invoices extends core_model_base_invoices
{
	
	function getNextInvoiceNumber($orderId) {
		global $core;
		core_db::col('SELECT max(index) + 1 FROM invoices WHERE order_id = '.$orderId);
	}
}
?>