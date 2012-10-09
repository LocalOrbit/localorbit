<?php
class core_model_base_core_config_data extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'config_id','int',8,'','core_config_data'));
		$this->add_field(new core_model_field(1,'scope','string',-4,'','core_config_data'));
		$this->add_field(new core_model_field(2,'scope_id','int',8,'','core_config_data'));
		$this->add_field(new core_model_field(3,'path','string',-4,'','core_config_data'));
		$this->add_field(new core_model_field(4,'value','string',8000,'','core_config_data'));
		$this->init_data();
	}
}
?>