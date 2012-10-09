<?php
class core_model_base_paypal_api_debug extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'debug_id','int',8,'','paypal_api_debug'));
		$this->add_field(new core_model_field(1,'debug_at','timestamp',4,'','paypal_api_debug'));
		$this->add_field(new core_model_field(2,'request_body','string',8000,'','paypal_api_debug'));
		$this->add_field(new core_model_field(3,'response_body','string',8000,'','paypal_api_debug'));
		$this->init_data();
	}
}
?>