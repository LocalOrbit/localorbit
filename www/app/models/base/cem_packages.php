<?php
class core_model_base_cem_packages extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'package_id','int',8,'','cem_packages'));
		$this->add_field(new core_model_field(1,'service_id','int',8,'','cem_packages'));
		$this->add_field(new core_model_field(2,'license_id','int',8,'','cem_packages'));
		$this->add_field(new core_model_field(3,'module_id','int',8,'','cem_packages'));
		$this->add_field(new core_model_field(4,'identifier','string',-4,'','cem_packages'));
		$this->add_field(new core_model_field(5,'title','string',-4,'','cem_packages'));
		$this->add_field(new core_model_field(6,'version','float',10,'2','cem_packages'));
		$this->add_field(new core_model_field(7,'identifier_rollback','string',-4,'','cem_packages'));
		$this->add_field(new core_model_field(8,'last_update','timestamp',4,'','cem_packages'));
		$this->add_field(new core_model_field(9,'update_available','int',8,'','cem_packages'));
		$this->add_field(new core_model_field(10,'auto_update','int',8,'','cem_packages'));
		$this->init_data();
	}
}
?>