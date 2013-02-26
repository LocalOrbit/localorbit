<?php
class core_model_base_googleoptimizer_code extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'code_id','int',8,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(1,'entity_id','int',8,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(2,'entity_type','string',-4,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(3,'store_id','int',8,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(4,'control_script','string',8000,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(5,'tracking_script','string',8000,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(6,'conversion_script','string',8000,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(7,'conversion_page','string',-4,'','googleoptimizer_code'));
		$this->add_field(new core_model_field(8,'additional_data','string',8000,'','googleoptimizer_code'));
		$this->init_data();
	}
}
?>