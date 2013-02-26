<?php
class core_model_base_cem_service_keys extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'key_id','int',8,'','cem_service_keys'));
		$this->add_field(new core_model_field(1,'service_id','int',8,'','cem_service_keys'));
		$this->add_field(new core_model_field(2,'key','string',-4,'','cem_service_keys'));
		$this->init_data();
	}
}
?>