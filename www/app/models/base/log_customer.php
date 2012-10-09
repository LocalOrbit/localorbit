<?php
class core_model_base_log_customer extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'log_id','int',8,'','log_customer'));
		$this->add_field(new core_model_field(1,'visitor_id','int',8,'','log_customer'));
		$this->add_field(new core_model_field(2,'customer_id','int',8,'','log_customer'));
		$this->add_field(new core_model_field(3,'login_at','timestamp',4,'','log_customer'));
		$this->add_field(new core_model_field(4,'logout_at','timestamp',4,'','log_customer'));
		$this->add_field(new core_model_field(5,'store_id','int',8,'','log_customer'));
		$this->init_data();
	}
}
?>