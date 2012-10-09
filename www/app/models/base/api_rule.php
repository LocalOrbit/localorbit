<?php
class core_model_base_api_rule extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rule_id','int',8,'','api_rule'));
		$this->add_field(new core_model_field(1,'role_id','int',8,'','api_rule'));
		$this->add_field(new core_model_field(2,'resource_id','string',-4,'','api_rule'));
		$this->add_field(new core_model_field(3,'privileges','string',-4,'','api_rule'));
		$this->add_field(new core_model_field(4,'assert_id','int',8,'','api_rule'));
		$this->add_field(new core_model_field(5,'role_type','string',-4,'','api_rule'));
		$this->add_field(new core_model_field(6,'permission','string',-4,'','api_rule'));
		$this->init_data();
	}
}
?>