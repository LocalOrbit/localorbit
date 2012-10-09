<?php
class core_model_base_account_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ACCOUNT_TYPE','int',8,'','account_types'));
		$this->add_field(new core_model_field(1,'TYPE_NAME','string',-4,'','account_types'));
		$this->init_data();
	}
}
?>