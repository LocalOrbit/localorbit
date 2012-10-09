<?php
class core_model_base_unit_requests extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ureq_id','int',8,'','unit_requests'));
		$this->add_field(new core_model_field(1,'single_name','string',-4,'','unit_requests'));
		$this->add_field(new core_model_field(2,'plural_name','string',-4,'','unit_requests'));
		$this->add_field(new core_model_field(3,'user_id','int',8,'','unit_requests'));
		$this->add_field(new core_model_field(4,'creation_date','timestamp',4,'','unit_requests'));
		$this->init_data();
	}
}
?>