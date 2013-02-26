<?php
class core_model_base_core_resource extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'code','string',-4,'','core_resource'));
		$this->add_field(new core_model_field(1,'version','string',-4,'','core_resource'));
		$this->init_data();
	}
}
?>