<?php
class core_model_base_invoices extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'invoice_id','int',8,'','invoices'));
		$this->add_field(new core_model_field(1,'first_invoice_date','int',8,'','invoices'));
		$this->add_field(new core_model_field(2,'due_date','int',8,'','invoices'));
		$this->add_field(new core_model_field(3,'creation_date','int',8,'','invoices'));
		$this->init_data();
	}
}
?>