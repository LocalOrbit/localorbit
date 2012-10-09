<?php
class core_model_base_log_visitor_online extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'visitor_id','int',8,'','log_visitor_online'));
		$this->add_field(new core_model_field(1,'visitor_type','string',-4,'','log_visitor_online'));
		$this->add_field(new core_model_field(2,'remote_addr','int',8,'','log_visitor_online'));
		$this->add_field(new core_model_field(3,'first_visit_at','timestamp',4,'','log_visitor_online'));
		$this->add_field(new core_model_field(4,'last_visit_at','timestamp',4,'','log_visitor_online'));
		$this->add_field(new core_model_field(5,'customer_id','int',8,'','log_visitor_online'));
		$this->add_field(new core_model_field(6,'last_url','string',-4,'','log_visitor_online'));
		$this->init_data();
	}
}
?>