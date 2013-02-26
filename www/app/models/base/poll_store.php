<?php
class core_model_base_poll_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'poll_id','int',8,'','poll_store'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','poll_store'));
		$this->init_data();
	}
}
?>