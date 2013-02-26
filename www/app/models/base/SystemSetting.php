<?php
class core_model_base_SystemSetting extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'SYSTEM_SETTINGS_ID','int',8,'','SystemSetting'));
		$this->add_field(new core_model_field(1,'NAME','string',-4,'','SystemSetting'));
		$this->add_field(new core_model_field(2,'VALUE','string',8000,'','SystemSetting'));
		$this->init_data();
	}
}
?>