<?php
class core_model_base_service_fee_schedules extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'sfs_id','int',8,'','service_fee_schedules'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','service_fee_schedules'));
		$this->init_data();
	}
}
?>