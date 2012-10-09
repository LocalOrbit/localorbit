<?php
class core_model_base_core_translate extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'key_id','int',8,'','core_translate'));
		$this->add_field(new core_model_field(1,'string','string',-4,'','core_translate'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','core_translate'));
		$this->add_field(new core_model_field(3,'translate','string',-4,'','core_translate'));
		$this->add_field(new core_model_field(4,'locale','string',-4,'','core_translate'));
		$this->init_data();
	}
}
?>