<?php
class core_model_base_log_visitor extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'visitor_id','int',8,'','log_visitor'));
		$this->add_field(new core_model_field(1,'session_id','string',-4,'','log_visitor'));
		$this->add_field(new core_model_field(2,'first_visit_at','timestamp',4,'','log_visitor'));
		$this->add_field(new core_model_field(3,'last_visit_at','timestamp',4,'','log_visitor'));
		$this->add_field(new core_model_field(4,'last_url_id','int',8,'','log_visitor'));
		$this->add_field(new core_model_field(5,'store_id','int',8,'','log_visitor'));
		$this->init_data();
	}
}
?>