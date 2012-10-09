<?php
class core_model_base_timezones extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tz_id','int',8,'','timezones'));
		$this->add_field(new core_model_field(1,'tz_name','string',-4,'','timezones'));
		$this->add_field(new core_model_field(2,'offset_seconds','int',8,'','timezones'));
		$this->add_field(new core_model_field(3,'tz_code','string',-4,'','timezones'));
		$this->init_data();
	}
}
?>