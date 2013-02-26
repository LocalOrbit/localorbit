<?php
class core_model_base_organizations_to_domains extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'otd_id','int',8,'','organizations_to_domains'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','organizations_to_domains'));
		$this->add_field(new core_model_field(2,'org_id','int',8,'','organizations_to_domains'));
		$this->add_field(new core_model_field(3,'orgtype_id','int',8,'','organizations_to_domains'));
		$this->add_field(new core_model_field(4,'is_home','int',8,'','organizations_to_domains'));
		$this->init_data();
	}
}
?>