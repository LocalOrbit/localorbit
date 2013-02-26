<?php
class core_model_base_log_quote extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'quote_id','int',8,'','log_quote'));
		$this->add_field(new core_model_field(1,'visitor_id','int',8,'','log_quote'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','log_quote'));
		$this->add_field(new core_model_field(3,'deleted_at','timestamp',4,'','log_quote'));
		$this->init_data();
	}
}
?>