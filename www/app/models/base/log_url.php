<?php
class core_model_base_log_url extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'url_id','int',8,'','log_url'));
		$this->add_field(new core_model_field(1,'visitor_id','int',8,'','log_url'));
		$this->add_field(new core_model_field(2,'visit_time','timestamp',4,'','log_url'));
		$this->init_data();
	}
}
?>