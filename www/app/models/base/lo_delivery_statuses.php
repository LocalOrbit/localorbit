<?php
class core_model_base_lo_delivery_statuses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ldstat_id','int',8,'','lo_delivery_statuses'));
		$this->add_field(new core_model_field(1,'delivery_status','string',-4,'','lo_delivery_statuses'));
		$this->init_data();
	}
}
?>