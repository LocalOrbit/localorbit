<?php
class core_model_base_payables extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payable_id','int',8,'','payables'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','payables'));
		$this->add_field(new core_model_field(2,'from_org_id','int',8,'','payables'));
		$this->add_field(new core_model_field(3,'to_org_id','int',8,'','payables'));
		$this->add_field(new core_model_field(4,'payable_type','string',-4,'','payables'));
		$this->add_field(new core_model_field(5,'parent_obj_id','int',8,'','payables'));
		$this->add_field(new core_model_field(6,'amount','float',10,'2','payables'));
		$this->add_field(new core_model_field(7,'invoice_id','int',8,'','payables'));
		$this->add_field(new core_model_field(8,'creation_date','int',8,'','payables'));
		$this->init_data();
	}
}
?>