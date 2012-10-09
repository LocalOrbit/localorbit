<?php
class core_model_base_paygate_authorizenet_debug extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'debug_id','int',8,'','paygate_authorizenet_debug'));
		$this->add_field(new core_model_field(1,'request_body','string',8000,'','paygate_authorizenet_debug'));
		$this->add_field(new core_model_field(2,'response_body','string',8000,'','paygate_authorizenet_debug'));
		$this->add_field(new core_model_field(3,'request_serialized','string',8000,'','paygate_authorizenet_debug'));
		$this->add_field(new core_model_field(4,'result_serialized','string',8000,'','paygate_authorizenet_debug'));
		$this->add_field(new core_model_field(5,'request_dump','string',8000,'','paygate_authorizenet_debug'));
		$this->add_field(new core_model_field(6,'result_dump','string',8000,'','paygate_authorizenet_debug'));
		$this->init_data();
	}
}
?>