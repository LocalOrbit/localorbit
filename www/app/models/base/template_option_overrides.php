<?php
class core_model_base_template_option_overrides extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'optover_id','int',8,'','template_option_overrides'));
		$this->add_field(new core_model_field(1,'tempopt_id','int',8,'','template_option_overrides'));
		$this->add_field(new core_model_field(2,'domain_id','int',8,'','template_option_overrides'));
		$this->add_field(new core_model_field(3,'override_value','string',-4,'','template_option_overrides'));
		$this->init_data();
	}
}
?>