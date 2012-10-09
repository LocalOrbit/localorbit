<?php
class core_model_base_updateEmailList extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'Name','string',-4,'','updateEmailList'));
		$this->add_field(new core_model_field(1,'SignedUp','timestamp',4,'','updateEmailList'));
		$this->add_field(new core_model_field(2,'Email','string',-4,'','updateEmailList'));
		$this->add_field(new core_model_field(3,'ZipCode','int',8,'','updateEmailList'));
		$this->add_field(new core_model_field(4,'Message','string',8000,'','updateEmailList'));
		$this->init_data();
	}
}
?>