<?php
class core_model_base_configuration_overrides extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'oconf_id','int',8,'','configuration_overrides'));
		$this->add_field(new core_model_field(1,'conf_id','int',8,'','configuration_overrides'));
		$this->add_field(new core_model_field(2,'domain_id','int',8,'','configuration_overrides'));
		$this->add_field(new core_model_field(3,'org_id','int',8,'','configuration_overrides'));
		$this->add_field(new core_model_field(4,'override_value','string',-4,'','configuration_overrides'));
		$this->init_data();
	}
}
?>