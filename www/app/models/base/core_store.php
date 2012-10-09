<?php
class core_model_base_core_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'store_id','int',8,'','core_store'));
		$this->add_field(new core_model_field(1,'code','string',-4,'','core_store'));
		$this->add_field(new core_model_field(2,'website_id','int',8,'','core_store'));
		$this->add_field(new core_model_field(3,'group_id','int',8,'','core_store'));
		$this->add_field(new core_model_field(4,'name','string',-4,'','core_store'));
		$this->add_field(new core_model_field(5,'sort_order','int',8,'','core_store'));
		$this->add_field(new core_model_field(6,'is_active','int',8,'','core_store'));
		$this->init_data();
	}
}
?>