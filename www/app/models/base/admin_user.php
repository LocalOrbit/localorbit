<?php
class core_model_base_admin_user extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'user_id','int',8,'','admin_user'));
		$this->add_field(new core_model_field(1,'firstname','string',-4,'','admin_user'));
		$this->add_field(new core_model_field(2,'lastname','string',-4,'','admin_user'));
		$this->add_field(new core_model_field(3,'email','string',-4,'','admin_user'));
		$this->add_field(new core_model_field(4,'username','string',-4,'','admin_user'));
		$this->add_field(new core_model_field(5,'password','string',-4,'','admin_user'));
		$this->add_field(new core_model_field(6,'created','timestamp',4,'','admin_user'));
		$this->add_field(new core_model_field(7,'modified','timestamp',4,'','admin_user'));
		$this->add_field(new core_model_field(8,'logdate','timestamp',4,'','admin_user'));
		$this->add_field(new core_model_field(9,'lognum','int',8,'','admin_user'));
		$this->add_field(new core_model_field(10,'reload_acl_flag','int',8,'','admin_user'));
		$this->add_field(new core_model_field(11,'is_active','int',8,'','admin_user'));
		$this->add_field(new core_model_field(12,'extra','string',8000,'','admin_user'));
		$this->init_data();
	}
}
?>