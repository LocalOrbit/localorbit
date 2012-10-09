<?php
class core_model_base_cem_services extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'service_id','int',8,'','cem_services'));
		$this->add_field(new core_model_field(1,'url','string',-4,'','cem_services'));
		$this->init_data();
	}
}
?>