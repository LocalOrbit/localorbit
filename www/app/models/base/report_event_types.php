<?php
class core_model_base_report_event_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'event_type_id','int',8,'','report_event_types'));
		$this->add_field(new core_model_field(1,'event_name','string',-4,'','report_event_types'));
		$this->add_field(new core_model_field(2,'customer_login','int',8,'','report_event_types'));
		$this->init_data();
	}
}
?>