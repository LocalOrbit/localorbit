<?php
class core_model_base_users extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','users'));
		$this->add_field(new core_model_field(1,'email','string',-4,'','users'));
		$this->add_field(new core_model_field(2,'account_type','int',8,'','users'));
		$this->add_field(new core_model_field(3,'account_type_name','string',-4,'','users'));
		$this->add_field(new core_model_field(4,'website_id','int',8,'','users'));
		$this->add_field(new core_model_field(5,'website_name','string',-4,'','users'));
		$this->add_field(new core_model_field(6,'first_name','string',-4,'','users'));
		$this->add_field(new core_model_field(7,'last_name','string',-4,'','users'));
		$this->init_data();
	}
}
?>