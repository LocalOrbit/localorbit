<?php
class core_model_base_api_session extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'user_id','int',8,'','api_session'));
		$this->add_field(new core_model_field(1,'logdate','timestamp',4,'','api_session'));
		$this->add_field(new core_model_field(2,'sessid','string',-4,'','api_session'));
		$this->init_data();
	}
}
?>