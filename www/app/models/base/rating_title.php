<?php
class core_model_base_rating_title extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rating_id','int',8,'','rating_title'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','rating_title'));
		$this->add_field(new core_model_field(2,'value','string',-4,'','rating_title'));
		$this->init_data();
	}
}
?>