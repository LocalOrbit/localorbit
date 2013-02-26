<?php
class core_model_base_Version extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'VERSION','string',-4,'','Version'));
		$this->add_field(new core_model_field(1,'VERSION_NUM','string',-4,'','Version'));
		$this->init_data();
	}
}
?>