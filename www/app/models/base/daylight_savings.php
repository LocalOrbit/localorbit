<?php
class core_model_base_daylight_savings extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ds_id','int',8,'','daylight_savings'));
		$this->add_field(new core_model_field(1,'ds_year','int',8,'','daylight_savings'));
		$this->add_field(new core_model_field(2,'ds_start','int',8,'','daylight_savings'));
		$this->add_field(new core_model_field(3,'ds_end','int',8,'','daylight_savings'));
		$this->init_data();
	}
}
?>