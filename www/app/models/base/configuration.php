<?php
class core_model_base_configuration extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'conf_id','int',8,'','configuration'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','configuration'));
		$this->add_field(new core_model_field(2,'default_value','string',-4,'','configuration'));
		$this->init_data();
	}
}
?>