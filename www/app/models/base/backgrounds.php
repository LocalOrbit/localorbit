<?php
class core_model_base_backgrounds extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'background_id','int',8,'','backgrounds'));
		$this->add_field(new core_model_field(1,'file_name','string',-4,'','backgrounds'));
		$this->add_field(new core_model_field(2,'is_available','int',8,'','backgrounds'));
		$this->init_data();
	}
}
?>