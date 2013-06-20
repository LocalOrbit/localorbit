<?php
class core_model_base_old_invoices extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'invoice_id','int',8,'','old_invoices'));
		$this->add_field(new core_model_field(1,'due_date','timestamp',4,'','old_invoices'));
		$this->add_field(new core_model_field(2,'from_org_id','int',8,'','old_invoices'));
		$this->add_field(new core_model_field(3,'to_org_id','int',8,'','old_invoices'));
		$this->add_field(new core_model_field(4,'amount','float',10,'2','old_invoices'));
		$this->add_field(new core_model_field(5,'is_imported','int',8,'','old_invoices'));
		$this->add_field(new core_model_field(6,'creation_date','timestamp',4,'','old_invoices'));
		$this->init_data();
	}
}
?>