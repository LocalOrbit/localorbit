<?php
class core_model_base_api_role extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'role_id','int',8,'','api_role'));
		$this->add_field(new core_model_field(1,'parent_id','int',8,'','api_role'));
		$this->add_field(new core_model_field(2,'tree_level','int',8,'','api_role'));
		$this->add_field(new core_model_field(3,'sort_order','int',8,'','api_role'));
		$this->add_field(new core_model_field(4,'role_type','string',-4,'','api_role'));
		$this->add_field(new core_model_field(5,'user_id','int',8,'','api_role'));
		$this->add_field(new core_model_field(6,'role_name','string',-4,'','api_role'));
		$this->init_data();
	}
}
?>