<?php
class core_model_base_products extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'prod_id','int',8,'','products'));
		$this->add_field(new core_model_field(1,'org_id','int',8,'','products'));
		$this->add_field(new core_model_field(2,'unit_id','int',8,'','products'));
		$this->add_field(new core_model_field(3,'name','string',-4,'','products'));
		$this->add_field(new core_model_field(4,'description','string',8000,'','products'));
		$this->add_field(new core_model_field(5,'how','string',8000,'','products'));
		$this->add_field(new core_model_field(6,'category_ids','string',-4,'','products'));
		$this->add_field(new core_model_field(7,'creation_date','timestamp',4,'','products'));
		$this->add_field(new core_model_field(8,'addr_id','int',8,'','products'));
		$this->add_field(new core_model_field(9,'who','string',8000,'','products'));
		$this->add_field(new core_model_field(10,'last_modified','timestamp',4,'','products'));
		$this->add_field(new core_model_field(11,'is_deleted','int',8,'','products'));
		$this->add_field(new core_model_field(12,'short_description','string',8000,'','products'));
		$this->init_data();
	}
}
?>