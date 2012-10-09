<?php
class core_model_base_log_url_info extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'url_id','int',8,'','log_url_info'));
		$this->add_field(new core_model_field(1,'url','string',-4,'','log_url_info'));
		$this->add_field(new core_model_field(2,'referer','string',-4,'','log_url_info'));
		$this->init_data();
	}
}
?>