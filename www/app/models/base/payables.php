<?php
class core_model_base_payables extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payable_id','int',8,'','payables'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','payables'));
		$this->add_field(new core_model_field(2,'payable_type_id','int',8,'','payables'));
		$this->add_field(new core_model_field(3,'parent_obj_id','int',8,'','payables'));
		$this->add_field(new core_model_field(4,'description','string',-4,'','payables'));
		$this->add_field(new core_model_field(5,'from_org_id','int',8,'','payables'));
		$this->add_field(new core_model_field(6,'to_org_id','int',8,'','payables'));
		$this->add_field(new core_model_field(7,'amount','float',10,'2','payables'));
		$this->add_field(new core_model_field(8,'invoice_id','int',8,'','payables'));
		$this->add_field(new core_model_field(9,'invoicable','int',8,'','payables'));
		$this->add_field(new core_model_field(10,'is_imported','int',8,'','payables'));
		$this->add_field(new core_model_field(11,'creation_date','timestamp',4,'','payables'));
		$this->init_data();
	}
}
?>