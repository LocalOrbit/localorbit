<?php
class core_model_base_core_flag extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'flag_id','int',8,'','core_flag'));
		$this->add_field(new core_model_field(1,'flag_code','string',-4,'','core_flag'));
		$this->add_field(new core_model_field(2,'state','int',8,'','core_flag'));
		$this->add_field(new core_model_field(3,'flag_data','string',8000,'','core_flag'));
		$this->add_field(new core_model_field(4,'last_update','timestamp',4,'','core_flag'));
		$this->init_data();
	}
}
?>