<?php
class core_model_base_v_invoices extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'due_date','timestamp',4,'','v_invoices'));
		$this->add_field(new core_model_field(1,'invoice_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(2,'amount','float',10,'2','v_invoices'));
		$this->add_field(new core_model_field(3,'from_org_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(4,'from_org_name','string',-4,'','v_invoices'));
		$this->add_field(new core_model_field(5,'to_org_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(6,'to_org_name','string',-4,'','v_invoices'));
		$this->add_field(new core_model_field(7,'amount_paid','float',10,'2','v_invoices'));
		$this->add_field(new core_model_field(8,'amount_due','float',10,'2','v_invoices'));
		$this->add_field(new core_model_field(9,'send_dates','string',8000,'','v_invoices'));
		$this->init_data();
	}
}
?>