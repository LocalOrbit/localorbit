<?php
class core_model_base_googlecheckout_api_debug extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'debug_id','int',8,'','googlecheckout_api_debug'));
		$this->add_field(new core_model_field(1,'dir','string',-4,'','googlecheckout_api_debug'));
		$this->add_field(new core_model_field(2,'url','string',-4,'','googlecheckout_api_debug'));
		$this->add_field(new core_model_field(3,'request_body','string',8000,'','googlecheckout_api_debug'));
		$this->add_field(new core_model_field(4,'response_body','string',8000,'','googlecheckout_api_debug'));
		$this->init_data();
	}
}
?>