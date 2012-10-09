<?php
class core_model_base_sendfriend_log extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'log_id','int',8,'','sendfriend_log'));
		$this->add_field(new core_model_field(1,'ip','int',8,'','sendfriend_log'));
		$this->add_field(new core_model_field(2,'time','int',8,'','sendfriend_log'));
		$this->init_data();
	}
}
?>