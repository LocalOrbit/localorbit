<?php
class core_model_base_rating_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rating_id','int',8,'','rating_store'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','rating_store'));
		$this->init_data();
	}
}
?>