<?php
class core_model_base_log_visitor_info extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'visitor_id','int',8,'','log_visitor_info'));
		$this->add_field(new core_model_field(1,'http_referer','string',-4,'','log_visitor_info'));
		$this->add_field(new core_model_field(2,'http_user_agent','string',-4,'','log_visitor_info'));
		$this->add_field(new core_model_field(3,'http_accept_charset','string',-4,'','log_visitor_info'));
		$this->add_field(new core_model_field(4,'http_accept_language','string',-4,'','log_visitor_info'));
		$this->add_field(new core_model_field(5,'server_addr','int',8,'','log_visitor_info'));
		$this->add_field(new core_model_field(6,'remote_addr','int',8,'','log_visitor_info'));
		$this->init_data();
	}
}
?>