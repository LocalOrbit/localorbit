<?php
class core_model_base_log_summary extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'summary_id','int',8,'','log_summary'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','log_summary'));
		$this->add_field(new core_model_field(2,'type_id','int',8,'','log_summary'));
		$this->add_field(new core_model_field(3,'visitor_count','int',8,'','log_summary'));
		$this->add_field(new core_model_field(4,'customer_count','int',8,'','log_summary'));
		$this->add_field(new core_model_field(5,'add_date','timestamp',4,'','log_summary'));
		$this->init_data();
	}
}
?>