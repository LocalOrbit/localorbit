<?php
class core_model_base_OrbitAdmin extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ORBIT_ID','int',8,'','OrbitAdmin'));
		$this->add_field(new core_model_field(1,'USER_ID','int',8,'','OrbitAdmin'));
		$this->init_data();
	}
}
?>