<?php
class core_model_base_template_options extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tempopt_id','int',8,'','template_options'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','template_options'));
		$this->add_field(new core_model_field(2,'default_value','string',-4,'','template_options'));
		$this->add_field(new core_model_field(3,'value_type','string',-4,'','template_options'));
		$this->init_data();
	}
}
?>