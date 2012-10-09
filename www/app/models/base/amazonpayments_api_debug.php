<?php
class core_model_base_amazonpayments_api_debug extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'debug_id','int',8,'','amazonpayments_api_debug'));
		$this->add_field(new core_model_field(1,'transaction_id','string',-4,'','amazonpayments_api_debug'));
		$this->add_field(new core_model_field(2,'debug_at','timestamp',4,'','amazonpayments_api_debug'));
		$this->add_field(new core_model_field(3,'request_body','string',8000,'','amazonpayments_api_debug'));
		$this->add_field(new core_model_field(4,'response_body','string',8000,'','amazonpayments_api_debug'));
		$this->init_data();
	}
}
?>