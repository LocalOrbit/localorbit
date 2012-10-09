<?php
class core_model_base_OrbitPermission extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'PERMISSION_ID','int',8,'','OrbitPermission'));
		$this->add_field(new core_model_field(1,'USER_ID','int',8,'','OrbitPermission'));
		$this->add_field(new core_model_field(2,'ROLE_ID','int',8,'','OrbitPermission'));
		$this->add_field(new core_model_field(3,'PERMISSION_TYPE','int',8,'','OrbitPermission'));
		$this->add_field(new core_model_field(4,'PERMISSION','int',8,'','OrbitPermission'));
		$this->add_field(new core_model_field(5,'OBJECT_ID','int',8,'','OrbitPermission'));
		$this->init_data();
	}
}
?>