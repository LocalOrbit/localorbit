<?php
class core_model_base_lo_fulfillment_order_status_changes extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lo_fscid','int',8,'','lo_fulfillment_order_status_changes'));
		$this->add_field(new core_model_field(1,'lo_foid','int',8,'','lo_fulfillment_order_status_changes'));
		$this->add_field(new core_model_field(2,'user_id','int',8,'','lo_fulfillment_order_status_changes'));
		$this->add_field(new core_model_field(3,'creation_date','timestamp',4,'','lo_fulfillment_order_status_changes'));
		$this->add_field(new core_model_field(4,'ldstat_id','int',8,'','lo_fulfillment_order_status_changes'));
		$this->add_field(new core_model_field(5,'lsps_id','int',8,'','lo_fulfillment_order_status_changes'));
		$this->init_data();
	}
}
?>