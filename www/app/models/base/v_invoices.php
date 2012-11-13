<?php
class core_model_base_v_invoices extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'invoice_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(1,'due_date','timestamp',4,'','v_invoices'));
		$this->add_field(new core_model_field(2,'amount','float',10,'2','v_invoices'));
		$this->add_field(new core_model_field(3,'creation_date','timestamp',4,'','v_invoices'));
		$this->add_field(new core_model_field(4,'from_org_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(5,'from_org_name','string',-4,'','v_invoices'));
		$this->add_field(new core_model_field(6,'to_org_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(7,'to_org_name','string',-4,'','v_invoices'));
		$this->add_field(new core_model_field(8,'from_domain_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(9,'from_domain_name','string',-4,'','v_invoices'));
		$this->add_field(new core_model_field(10,'to_domain_id','int',8,'','v_invoices'));
		$this->add_field(new core_model_field(11,'to_domain_name','string',-4,'','v_invoices'));
		$this->add_field(new core_model_field(12,'amount_paid','float',10,'2','v_invoices'));
		$this->add_field(new core_model_field(13,'amount_due','float',10,'2','v_invoices'));
		$this->add_field(new core_model_field(14,'send_dates','blob',8000000,'','v_invoices'));
		$this->add_field(new core_model_field(15,'payable_info','blob',8000000,'','v_invoices'));
		$this->init_data();
	}
}
?>