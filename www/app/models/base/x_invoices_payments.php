<?php
class core_model_base_x_invoices_payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'x_invoices_payments_id','int',8,'','x_invoices_payments'));
		$this->add_field(new core_model_field(1,'invoice_id','int',8,'','x_invoices_payments'));
		$this->add_field(new core_model_field(2,'payment_id','int',8,'','x_invoices_payments'));
		$this->add_field(new core_model_field(3,'amount_paid','float',10,'2','x_invoices_payments'));
		$this->init_data();
	}
}
?>