<?php
class core_model_base_OrbitRole extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ROLE_ID','int',8,'','OrbitRole'));
		$this->add_field(new core_model_field(1,'ROLE_NAME','string',-4,'','OrbitRole'));
		$this->init_data();
	}
}
?>